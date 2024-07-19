package fr.irisa.cairn.gecos.model.hls.idg.codegen.lowering.uclid

import fr.irisa.cairn.gecos.model.analysis.forloops.ForLoopAnalyser
import fr.irisa.cairn.tools.ecore.query.EMFUtils
import gecos.annotations.PragmaAnnotation
import gecos.blocks.BasicBlock
import gecos.blocks.Block
import gecos.blocks.CaseBlock
import gecos.blocks.CompositeBlock
import gecos.blocks.DoWhileBlock
import gecos.blocks.ForBlock
import gecos.blocks.IfBlock
import gecos.blocks.SwitchBlock
import gecos.blocks.WhileBlock
import gecos.core.ISymbolUse
import gecos.core.Procedure
import gecos.core.ProcedureSymbol
import gecos.core.Symbol
import gecos.gecosproject.GecosProject
import gecos.gecosproject.GecosSourceFile
import gecos.instrs.CallInstruction
import gecos.instrs.ComplexInstruction
import gecos.instrs.CondInstruction
import gecos.instrs.EnumeratorInstruction
import gecos.instrs.FieldInstruction
import gecos.instrs.GenericInstruction
import gecos.instrs.Instruction
import gecos.instrs.IntInstruction
import gecos.instrs.LabelInstruction
import gecos.instrs.RetInstruction
import gecos.instrs.SetInstruction
import gecos.instrs.SimpleArrayInstruction
import gecos.instrs.SymbolInstruction
import gecos.types.ArrayType
import gecos.types.BaseType
import gecos.types.BoolType
import gecos.types.EnumType
import gecos.types.FunctionType
import gecos.types.IntegerType
import gecos.types.PtrType
import gecos.types.RecordType
import gecos.types.Type
import gecos.types.VoidType
import java.io.File
import java.io.PrintStream
import java.util.List
import java.util.ArrayList
import java.text.ParseException
import gecos.types.impl.ACIntTypeImpl
import gecos.types.OverflowMode
import gecos.instrs.ConvertInstruction
import gecos.types.ACIntType
import gecos.types.AliasType
import gecos.types.FloatType
import java.util.Set

class GecosToUclidConverter {

	static Procedure currentProc

	def static apply(GecosProject proj, String outPath) {

		val ps = proj.getSources.head
		if (!new File(outPath).exists) {
			new File(outPath).mkdirs
		}
		val pstr = new PrintStream(new File(outPath+ File.separator+  proj.name + ".ucl"))
		pstr.append(convert(ps))
		pstr.close
	}

	def static apply(Procedure procedure, String outPath) {
	
		if (!new File(outPath).exists) {
			new File(outPath).mkdirs
		}
			val pstr = new PrintStream(new File(outPath+ File.separator+  procedure.containingProject.name +
				"_"+ procedure.symbolName+ ".ucl"))
			pstr.append(convert(procedure))
			pstr.close
	}


	def static toString(Iterable<?> i, String sep) {
		if (!i.empty)
			i.map[toString].reduce[p1, p2|p1 + sep + p2]
		else
			""
	}

	def static dispatch String convertInstr(Instruction i) {
		i.class.simpleName
	}

	def static dispatch String convertInstr(ComplexInstruction i) {
		//i.class.simpleName + "[" + i.listChildren.map[convertInstr] + "]"
		'''// No equivalent to «i.class.simpleName»'''
	}
	
	def static dispatch String convertInstr(ConvertInstruction i) {
		if (i.listChildren.length != 1)
			throw new RuntimeException("Casting multiple targets")
		
		val target = i.listChildren.first
		if (i.type == target.type)
			return convertInstr(target)
		
		if (i.type instanceof BoolType) {
			if (target.type instanceof ACIntType) {
				return '''«convertInstr(target)» == 0bv«(target.type as ACIntType).bitwidth»'''
			}
			if (target.type instanceof IntegerType) {
				return '''«convertInstr(target)» == 0'''
			}
			
		}
		
		if (i.type instanceof ACIntType) {
			val bv = i.type as ACIntType
			
			return convertInstr(target) + "bv" + bv.bitwidth
		}
		throw new RuntimeException("No equivalent to casting in UCLID")
	}

	def static dispatch String convertInstr(EnumeratorInstruction i) {
		correctIdentifier(i.enumerator.name)
	}

	def static dispatch String convertInstr(LabelInstruction i) {
		"//";
	}


	def static dispatch String convertInstr(CallInstruction call) {
		val psym = call.procedureSymbol
		if (psym.isUninterpreted) {
			call.address.convertInstr + "(" + call.args.map[convertInstr].toString(", ") + ")"
		} else if (psym.procedure !== null) { 
			if (psym.functionType.returnType instanceof VoidType) {
				return "call " + call.address.convertInstr + "(" + call.args.map[convertInstr].toString(", ") + ")"
			} else {
				if (tempVariables.empty || tempCallStorage.empty)
					return "failure"
				
				val variableName = "tmpvar_" + call.address.convertInstr + tempVariableCounter++
				val variableType = call.address.type.asFunction.returnType
				
				tempVariables.getLast.add(variableName + ": " + typeName(variableType))
				
				tempCallStorage.getLast.add(
					'''
					call («variableName») = «call.address.convertInstr»(«call.args.map[convertInstr].toString(", ")»);
					'''
				)
				return variableName
			}
		} else {
			if (psym.name=="printf") "some printf leftover"
			else call.address.convertInstr + "(" + call.args.map[convertInstr].toString(", ") + ")"
		}
	}

	def static dispatch String convertInstr(SetInstruction i) {
		val src = i.source
		if (src instanceof CallInstruction) {
			val psym = src.procedureSymbol
			if (psym.procedure !== null && !psym.uninterpreted) {
				if (!(psym.functionType.returnType instanceof VoidType)) {
					return "call (" + i.dest.convertInstr + ") = " + src.address.convertInstr + "(" +
						src.args.map[convertInstr].toString(", ") + ")"
				} else {
					throw new UnsupportedOperationException("NYI");
				}
			} else {
				i.dest.convertInstr+" = "+i.source.convertInstr
			}
		} else {
			i.dest.convertInstr + " = " + i.source.convertInstr
		}
	}

	def static dispatch String convertInstr(SymbolInstruction i) {
		correctIdentifier(i.symbolName)
	}

	def static dispatch String convertInstr(IntInstruction i) {
		switch(i.type) {
			BoolType :{ return (i.value==0)?"false":"true" }
			IntegerType :{ return (i.value.intValue.toString) }
		}
		
	}

	def static dispatch String convertInstr(FieldInstruction i) {
		i.expr.convertInstr + "." + i.field.name
	}

	def static dispatch String convertInstr(CondInstruction i) {
		convertInstr(i.cond)
	}

	def static dispatch String convertInstr(GenericInstruction i) {
		switch (i.name) {
			case "eq":
				"(" + convertInstr(i.children.get(0)) + " == " + convertInstr(i.children.get(1)) + ")"
			case "add":
				"(" + convertInstr(i.children.get(0)) + " + " + convertInstr(i.children.get(1)) + ")"
			case "sub":
				"(" + convertInstr(i.children.get(0)) + " - " + convertInstr(i.children.get(1)) + ")"
			case "neg":
				"(-" + convertInstr(i.children.get(0)) + ")"
			case "lt":
				"(" + convertInstr(i.children.get(0)) + " < " + convertInstr(i.children.get(1)) + ")"
			case "gt":
				"(" + convertInstr(i.children.get(0)) + " > " + convertInstr(i.children.get(1)) + ")"
			case "le":
				"(" + convertInstr(i.children.get(0)) + " <= " + convertInstr(i.children.get(1)) + ")"
			case "ge":
				"(" + convertInstr(i.children.get(0)) + " >= " + convertInstr(i.children.get(1)) + ")"
			case "neq":
				"(" + convertInstr(i.children.get(0)) + " != " + convertInstr(i.children.get(1)) + ")"
			case "mux":
				"if (" + convertInstr(i.children.get(0)) + ") then " + convertInstr(i.children.get(1)) +
				" else " + convertInstr(i.children.get(2)) 
			case "and":
				"(" + convertInstr(i.children.get(0)) + " & " + convertInstr(i.children.get(1)) + ")"
			case "or":
				"(" + convertInstr(i.children.get(0)) + " | " + convertInstr(i.children.get(1)) + ")"
			case "land":
				"(" + convertInstr(i.children.get(0)) + " && " + convertInstr(i.children.get(1)) + ")"
			case "lor":
				"(" +convertInstr(i.children.get(0)) + " || " + convertInstr(i.children.get(1)) + ")"
			case "lnot":
				"(!" + convertInstr(i.children.get(0)) + ")"
			default: {
				i.name + "(" + i.children.map[convertInstr].reduce[p1, p2|p1+ "," +p2]+ ")"
			}
		}

	}

	def static dispatch String convertInstr(RetInstruction i) {
		if(i.expr === null) return "//"
		
		if (i.expr instanceof CallInstruction) {
			val call = i.expr as CallInstruction
			return "call (ret_" + correctIdentifier(currentProc.symbolName) + ") = " + call.address.convertInstr + "(" +
						call.args.map[convertInstr].toString(",") + ")"
						
		}
		return "ret_" + correctIdentifier(currentProc.symbolName) + " = " + i.expr.convertInstr
	}

	def static dispatch String convertInstr(SimpleArrayInstruction i) {
		correctIdentifier(i.symbolName) + "[" + i.index.head.convertInstr + "]"
	}

	def static dispatch String convertBlock(Block b) {
		"// unsupported for " + b
	}

	def static dispatch String convertBlock(BasicBlock bb) {
		if (bb.instructionCount !== 0) {
			
			var tempCalls = new ArrayList<String>()
			tempCallStorage.add(tempCalls)
			
			val res = bb.instructions.map[convertInstr].filterNull.reduce[a, b|a + ";\n" + b] + ";"
			tempCallStorage.removeLast
			return '''
				«FOR st : tempCalls»
				«st»
				«ENDFOR»
				«res»
			'''
		}
		else
			""
	}

	def static dispatch String convertBlock(SwitchBlock bb) {
		'''
			case
			«FOR b:bb.cases»
			«convertCaseBlock(bb.dispatchBlock,b)»
			«ENDFOR»
			esac;
		'''
	}
	def static String convertCaseBlock(BasicBlock b, CaseBlock bb) {
		if (bb.entryBlock.instructions.empty) {
			'''
			default : {
				«convertBlock(bb.body)»	
			}'''
			
		} else {
			'''
			(«convertInstr(b.instructions.head)»==«convertInstr(bb.entryBlock.instructions.head)») : {
				«convertBlock(bb.body)»	
			}'''
		}
	}

	def static dispatch String convertBlock(CompositeBlock cb) {
		
		if (!cb.children.empty)
			cb.children.map[convertBlock].reduce[a, b|a + "\n" + b]
		else
			""
	}


	def static dispatch String convertBlock(IfBlock b) {
		var tempCalls = new ArrayList<String>()
		tempCallStorage.add(tempCalls)
		val cond = convertInstr((b.testBlock as BasicBlock).instructions.head)
		tempCallStorage.removeLast
		
		'''
			«FOR st : tempCalls»
			«st»
			«ENDFOR»
			if («cond») {	
				«convertBlock(b.thenBlock)» 
			}
			«IF b.elseBlock!==null»
			else {
				«convertBlock(b.elseBlock)»
			}
			«ENDIF»
		'''
	}

	def static dispatch String convertBlock(ForBlock b) {

		val analyzer = new ForLoopAnalyser(b)
		'''
			for «correctIdentifier(analyzer.iterationIndex.name)» in range («convertInstr(analyzer.startValue)»,«convertInstr(analyzer.stopValue)») {
				«convertBlock(b.bodyBlock)»
			}
		'''
	}
	
	static var List<List<String>> tempCallStorage = new ArrayList()

	def static dispatch String convertBlock(DoWhileBlock b) {
		var tempCalls = new ArrayList<String>()
		tempCallStorage.add(tempCalls)
		
		val cond = convertInstr((b.testBlock as BasicBlock).instructions.head)
		tempCallStorage.removeLast
		val body = convertBlock(b.bodyBlock)
		
		
		'''
			{
				«body»
			}
			«FOR st : tempCalls»
			«st»
			«ENDFOR»
			while («cond») {
				«body»
				«FOR st : tempCalls»
				«st»
				«ENDFOR»
			}
		'''
	}

	def static dispatch String convertBlock(WhileBlock b) {
		var tempCalls = new ArrayList<String>()
		tempCallStorage.add(tempCalls)
		
		val cond = convertInstr((b.testBlock as BasicBlock).instructions.head)
		tempCallStorage.removeLast
		val body = convertBlock(b.bodyBlock)
		
		'''
			«FOR st : tempCalls»
			«st»
			«ENDFOR»
			while («cond») {
				«body»
				«FOR st : tempCalls»
				«st»
				«ENDFOR»
			}
		'''
	}

	def static isUninterpreted(ProcedureSymbol psym) {
		val uclidPragma = psym.eAllContents.filter(PragmaAnnotation).filter[content.exists[it.contains("uclid")]].toList
		for(p :uclidPragma)
			if (p.content.exists[it.contains("uninterpreted")]) return true
		
		return false	
					
	}


	// used to store variables to declare for internal procedure calls
	static var List<Set<String>> tempVariables = new ArrayList()
	static var int tempVariableCounter

	def static convert(Procedure proc) {
		val locals = EMFUtils.eAllContentsInstancesOf(proc.body, Symbol) + proc.listParameters;
		val refs = EMFUtils.eAllContentsInstancesOf(proc.body, ISymbolUse);
		val extRefs = refs.reject[locals.contains(usedSymbol)].map[usedSymbol].reject(ProcedureSymbol).toSet
		val Set<Symbol> extRefsDeeper = refs
								.reject[locals.contains(usedSymbol)]
								.map[usedSymbol]
								.filter(ProcedureSymbol)
								.filter[p | p.procedure !== null]
								.filter[!uninterpreted]
								.map[
									p | {
										val locals1 = EMFUtils.eAllContentsInstancesOf(p.procedure.body, Symbol) +
														 p.procedure.listParameters;
										val refs1 = EMFUtils.eAllContentsInstancesOf(p.procedure.body, ISymbolUse)
										
										refs1
											.reject[locals1.contains(usedSymbol)]
											.map[usedSymbol]
											.reject(ProcedureSymbol).toSet
									}
								]
								.flatten
								.toSet
		
		val extRefsTotal = extRefs + extRefsDeeper
		
		val funType = proc.symbol.type as FunctionType
		val argsDecl = proc.listParameters.map[correctIdentifier(it.name) + ":" + typeName(it.type)]

		var temporaryVariables = newHashSet()
		tempVariableCounter = 0
		tempVariables.add(temporaryVariables)
		
		currentProc = proc
		val body1 = '''
			
				«FOR s:EMFUtils.eAllContentsInstancesOf(proc.body, Symbol).reject(ProcedureSymbol)»
				«declare(s)»
				«ENDFOR»
				«FOR decl : argsDecl»
					var «decl»;
				«ENDFOR»
				«FOR param : proc.listParameters»
					«correctIdentifier(param.name)» = «correctIdentifier(param.name)»_arg;
				«ENDFOR»
		'''
		val body2 = '''
				«convertBlock(proc.body)»
		'''
		
		val body = body1 + '''
				«FOR v : temporaryVariables»
					var «v»;
				«ENDFOR»
		''' + body2
		
		tempVariables.removeLast

		val sideffects = if(extRefsTotal.empty) "" else '''modifies «extRefsTotal.map[it.name].toString(",")»;'''
		return '''
			procedure «correctIdentifier(proc.symbol.name)»(«proc.listParameters.map[correctIdentifier(it.name) + "_arg: " + typeName(it.type)].toString(",")») «if (!(funType.returnType instanceof VoidType)) {'''returns ( ret_«proc.symbolName» : «typeName(funType.returnType)») 
			'''
		} else {
			""
		}»«sideffects» 
			{
			«body»
			}
		''';
	}

	def static dispatch String typeName(Type type) {
		"//Unsupported type " + type//throw new UnsupportedOperationException("Unsupported typeName() for " + type)
	}
	
	def static dispatch String typeName(VoidType type) {
		"Void"
	}
	
	def static dispatch String typeName(AliasType type) {
		correctIdentifier(type.name)
	}
	
	static var first_warning = true
	
	def static dispatch String typeName(ACIntTypeImpl type) {
		if (first_warning && type.getOverflowMode != OverflowMode.AC_WRAP) {
			System.out.println("Warning: UCLID supports only wrapping upon overflow. Defaulting to AC_WRAP")
			first_warning = false;	
		}
			
		
		"bv" + type.bitSize
	}
	

	def static dispatch String typeName(IntegerType type) {
		"integer"
	}

	def static dispatch String typeName(BoolType type) {
		"boolean"
	}
	
	def static dispatch String typeName(FloatType t) {
		if (t.half)
			"half"
		else if (t.single)
			"single"
		else if (t.double)
			"double"
		else if (t.longDouble)
			"double"
		else throw new RuntimeException("Invalid float type. Fix FloatType class first")
	}

	def static dispatch String typeName(PtrType s) {
		'''ptr_«s.base.typeName»'''
	}

	def static dispatch String typeName(ArrayType s) {
		'''array_«s.hashCode»'''
	}

	def static dispatch String typeName(RecordType type) {
		correctIdentifier(type.name)
	}

	def static dispatch String typeName(EnumType type) {
		correctIdentifier(type.name)
	}

	def static dispatch declareType(Type s) {
		"//Unsupported type " + s//throw new UnsupportedOperationException("TODO: auto-generated method stub fir " + s)
	}
	
	def static dispatch declareType(VoidType s) {
		"type Void = boolean;"
	}
	
	def static dispatch declareType(AliasType t) {
		
		'''type «correctIdentifier(t.name)» = «typeName(t.alias)»;'''
	}

	def static dispatch declareType(PtrType s) {
		'''type ptr_«s.base.typeName» = integer;'''
	}

	def static dispatch declareType(RecordType s) {
		'''
			type «correctIdentifier(s.name)» = record {
				«FOR f : s.fields SEPARATOR ","»
					«f.name» : «f.type.typeName»
				«ENDFOR»
				«IF s.fields.empty»
					_dummy123 : integer
				«ENDIF»
			};
		'''
	}

	def static dispatch declareType(ArrayType s) {
		if (s.base !== null)
			'''type array_«s.hashCode» = [integer]  «typeName(s.base)»;'''
	}

	def static dispatch declareType(BaseType s) {
		""
	}

	def static dispatch declareType(FunctionType s) {
		""
	}

	def static dispatch declareType(EnumType s) {
		'''type «correctIdentifier(s.name)» = enum {«s.enumerators.map[name].toString(",")» };'''
	}

	def static dispatch declare(ProcedureSymbol s) {
		if (s.procedure === null || s.uninterpreted) {
			val params = s.listParameters;
			var List<String> args = newArrayList
			for (i : 0 ..< s.listParameters.size) {
				if (!(params.get(i).type instanceof VoidType))
					args += "in_" + i + " : " + typeName(params.get(i).type)
			}

			val returnType = (s.type as FunctionType).returnType
			return '''function «correctIdentifier(s.name)»(«args.toString(",")») : «typeName(returnType)»;'''
			
		} else {
			convert(s.procedure)
		}
	}

	def static dispatch declare(Symbol s) {
		'''var «s.name» : «typeName(s.type)»;'''
	}


	def static extractInvariants(GecosSourceFile pset) {
		/*val str = new StringBuffer
		val pragmas =  pset.eAllContents.filter(PragmaAnnotation).toIterable
		for (p:pragmas) {
			val invs =  p.content.filter[it.contains("uclid::invariant")]
			for (inv: invs) {
				str.append(inv.replace("uclid::", "")+";\n")
			}
		}
		str.toString*/
		
		val initSpec = extractInitSpec(pset)
		val nextSpec = extractNextSpec(pset)
		val initImpl = extractInitImpl(pset)
		val nextImpl = extractNextImpl(pset)
		
		if (initSpec === null || nextSpec === null || initImpl === null || nextImpl === null)
			return ""
		
		val initSpecProc = initSpec.procedure
		val nextSpecProc = nextSpec.procedure
		val initImplProc = initImpl.procedure
		val nextImplProc = nextImpl.procedure
		
		if (initSpecProc === null || nextSpecProc === null || initImplProc === null || nextImplProc === null)
			return ""
		
		val specRefs = EMFUtils.eAllContentsInstancesOf(nextSpecProc.body, ISymbolUse);
		val specLocals = EMFUtils.eAllContentsInstancesOf(nextSpecProc.body, Symbol) + nextSpecProc.listParameters;
		val specExtRefs = specRefs.reject[specLocals.contains(usedSymbol)].map[usedSymbol].reject(ProcedureSymbol).toSet
		
		val implRefs = EMFUtils.eAllContentsInstancesOf(nextImplProc.body, ISymbolUse);
		val implLocals = EMFUtils.eAllContentsInstancesOf(nextImplProc.body, Symbol) + nextImplProc.listParameters;
		val implExtRefs = implRefs.reject[implLocals.contains(usedSymbol)].map[usedSymbol].reject(ProcedureSymbol).toSet
		
		val varToCheck = specExtRefs
									.filter[name.endsWith("_spec")]
									.filter[
										sym | !implExtRefs.filter[
											name == sym.name.substring(0, sym.name.length - "_spec".length)
										].empty
									].map[name]
		
		val implPragmas = EMFUtils.eAllContentsInstancesOf(nextImplProc.body, PragmaAnnotation).map[content].flatten
		val bestInitiationIntervalStr = implPragmas.findFirst[it.startsWith("HLS PIPELINE II=")]
		val worstInitiationIntervalStr = implPragmas.findFirst[it.startsWith("HLS PIPELINE worst II=")]
		
		val bestInitiationInterval = Integer.valueOf(bestInitiationIntervalStr.substring("HLS PIPELINE II=".length))
		val worstInitiationInterval = Integer.valueOf(worstInitiationIntervalStr.substring("HLS PIPELINE worst II=".length))
		
		
		'''
		invariant main_inv: (
				«FOR v : varToCheck»
					history(«v», «bestInitiationInterval») ==
					history(«v.substring(0, v.length - "_spec".length)», «bestInitiationInterval») &&
				«ENDFOR»
				«IF !varToCheck.empty»
					true
				«ENDIF»
				) ==> (
				«FOR v : varToCheck»
					«IF bestInitiationInterval - 1 > 0»
					history(«v», «bestInitiationInterval - 1») ==
					«ELSE»
					«v» ==
					«ENDIF»
					«v.substring(0, v.length - "_spec".length)» &&
				«ENDFOR»
				«IF !varToCheck.empty»
					true
				«ENDIF»
				) || (
				«FOR v : varToCheck»
					history(«v», «worstInitiationInterval») ==
					history(«v.substring(0, v.length - "_spec".length)», «worstInitiationInterval») &&
				«ENDFOR»
				«IF !varToCheck.empty»
					true
				«ENDIF»
				) ==> (
				«FOR v : varToCheck»
					«IF worstInitiationInterval - 1 > 0»
					history(«v», «worstInitiationInterval - 1») ==
					«ELSE»
					«v»
					«ENDIF»
					«v.substring(0, v.length - "_spec".length)» &&
				«ENDFOR»
				«IF !varToCheck.empty»
					true
				«ENDIF»
				);
		'''
	}

	def static extractCEX(GecosSourceFile pset) {
		val cex=  pset.eAllContents.filter(PragmaAnnotation).toIterable.map[content].flatten.findFirst[it.contains("uclid::print_cex")]
		if (cex!==null) cex.replace("uclid::", "vobj.")
		else ""
	}

	def static extractInductionDept(GecosSourceFile pset) {
		val cex=  pset.eAllContents.filter(PragmaAnnotation).toIterable.map[content].flatten.findFirst[it.contains("uclid::induction")]
		if (cex!==null) cex.replace("uclid::", "vobj=")
		else "induction"
	}

	def static convert(GecosSourceFile src) {
		
		var typesEncountered = <String>newHashSet()
		var miscEncountered = <String>newHashSet()
		var procEncountered = <String>newHashSet()
		
		var res = new StringBuffer("module main{\n\n")
		
		for (t : src.types) {
			if (!typesEncountered.contains(t.typeName)) {
				typesEncountered.add(t.typeName)
				res.append('\t').append(t.declareType).append('\n')
			}
		}
		
		for (s : src.symbols.reject(ProcedureSymbol)) {
			if (!miscEncountered.contains(s.name)) {
				miscEncountered.add(s.name)
				res.append('\t').append(s.declare).append('\n')
			}
		}
		
		for (p : src.symbols.filter(ProcedureSymbol).reject[name == "main"].reject[isTopLevel]) {
			if (
				(p.procedure === null || p.uninterpreted) &&
				!src.symbols
					.filter(ProcedureSymbol)
					.filter[name == p.name]
					.filter[procedure !== null]
					.filter[!uninterpreted]
					.empty
					)
					{
					}
			
			else if (!procEncountered.contains(p.name)) {
				procEncountered.add(p.name)
				res.append('\t').append(p.declare).append('\n')
			}
		}
		var tempVars = newHashSet()
		tempVariables.add(tempVars)
		
		val mainBlocks = '''
				init {
					t =0;
				«IF isTopLevelMode(src)»
					«extractInitTopLevel(src)»
				«ENDIF»
				«FOR s : src.symbols.filter(ProcedureSymbol).filter[name.startsWith("init_")]»
					call «s.name»();
				«ENDFOR»
				}
			
				next {
					t'= t +1;
				«IF isTopLevelMode(src)»
					«extractNextTopLevel(src)»
				«ENDIF»
				«FOR s : src.symbols.filter(ProcedureSymbol).filter[name.startsWith("next_")]»
					call «correctIdentifier(s.name)»();
				«ENDFOR»
				}
		'''
		
		res.append(
			'''
			var t : integer;
			var _finished123: boolean;
			«FOR tmp_var : tempVars»
			var «tmp_var»;
			«ENDFOR»
			«mainBlocks»	
			
						«extractInvariants(src)»
					
						control {
							«extractInductionDept(src)»;
							check;
							print_results;
					 		«extractCEX(src)»
						}
						}
			'''
		)
		
		return res.toString()
		
		
		/*'''
		module main {
		
			«FOR s : src.types»
				«s.declareType»
			«ENDFOR»
		
			«FOR s : src.symbols.reject(ProcedureSymbol)»
				«s.declare»
			«ENDFOR»
			«IF isTopLevelMode(src)»
			var _finished123: boolean;
			«ENDIF»
		
			«FOR s : src.symbols.filter(ProcedureSymbol).reject[name=="main"].reject[isTopLevel]»
				«IF (s.procedure === null || s.uninterpreted) 
					&& !src.symbols.filter(ProcedureSymbol).filter[name == s.name].empty»
				«s.declare»
				«ENDIF»
			«ENDFOR»
			
			var t : integer;
			init {
				t =0;
			«IF isTopLevelMode(src)»
				«extractInitTopLevel(src)»
			«ELSE»
			«FOR s : src.symbols.filter(ProcedureSymbol).filter[name.startsWith("init_")]»
				call «s.name»();
			«ENDFOR»
			«ENDIF»
			}
		
			next {
				t'= t +1;
			«IF isTopLevelMode(src)»
				«extractNextTopLevel(src)»
			«ELSE»
			«FOR s : src.symbols.filter(ProcedureSymbol).filter[name.startsWith("next_")]»
				call «correctIdentifier(s.name)»();
			«ENDFOR»
			«ENDIF»
			}

			«extractInvariants(src)»
		
			control {
				«extractInductionDept(src)»;
				check;
				print_results;
		 		«extractCEX(src)»
			}
			
		}
		'''*/
	}
	
	def static correctIdentifier(String s) {
		val reserved = #["in", "out", "next", "init", "module",
						 "control", "induction", "bmc", "check",
						 "print_results", "print_cex"
		]
		if (reserved.contains(s))
			s + "___" + s.hashCode().toString()
		else
			s
	}


	def static isTopLevelMode(GecosSourceFile src) {
		!src.symbols
			.filter(ProcedureSymbol)
			.filter[isTopLevel].isEmpty
	}


	def static isTopLevel(ProcedureSymbol s) {
		!s.eAllContents
		  .filter(PragmaAnnotation)
		  .filter[content.exists[it.contains("toplevel")]]
		  .isEmpty
	}
	
	

	
	def static extractInitTopLevel(GecosSourceFile src) {
		val main = src.symbols
		   .filter(ProcedureSymbol)
		   .filter[isTopLevel]
		   .head
		   .procedure // only call this function when isTopLevelMode is true, NPE here otherwise
		
		if (main === null)
			return ""
		
		val labels = main.body.listAllChildrenInstructions.filter(LabelInstruction)
		
		val initLabel = labels.findFirst[name == "init"]
		'''
				_finished123 = false;
				«convertBlock(initLabel.basicBlock)»
		'''
	}
	
	def static extractNextTopLevel(GecosSourceFile src) {
		val main = src.symbols
		   .filter(ProcedureSymbol)
		   .filter[isTopLevel]
		   .head
		   .procedure // only call this function when isTopLevelMode is true, NPE here otherwise
		
		if (main === null)
			return ""
		
		val labels = main.body.listAllChildrenInstructions.filter(LabelInstruction)
		
		val initLabel = labels.findFirst[name == "init"]
		val initLabelAsBlock = initLabel.basicBlock
		
		val index = (initLabelAsBlock.parent as CompositeBlock).children.indexOf(initLabelAsBlock)
		val initBlock = (initLabelAsBlock.parent as CompositeBlock).children.get(index + 1)
		
		if (initBlock instanceof WhileBlock) {
			val whyle = initBlock as WhileBlock
		
			'''
					if («convertInstr((whyle.testBlock as BasicBlock).instructions.head)») {
						_finished123' = true;
					}
					if (!_finished123') {
						«convertBlock(whyle.bodyBlock)»
					}
			'''
		} else if (initBlock instanceof DoWhileBlock) {
			val whyle = initBlock as DoWhileBlock
		
			'''
					if (!(«convertInstr((whyle.testBlock as BasicBlock).instructions.head)»)) {
						_finished123' = true;
					}
					if (!_finished123') {
						«convertBlock(whyle.bodyBlock)»
					}
			'''
		} else throw new RuntimeException("Expected while")
		
	}
	


	def static extractInitSpec(GecosSourceFile s) {
		s.symbols
			.filter(ProcedureSymbol)
			.filter[name.startsWith("init_")]
			.filter[p | !p.eAllContents
		  					.filter(PragmaAnnotation)
		  					.filter[content.exists[it.contains("spec")]]
		  					.isEmpty
		  	]
		  	.head
	}
	
	def static extractNextSpec(GecosSourceFile s) {
		s.symbols
			.filter(ProcedureSymbol)
			.filter[name.startsWith("next_")]
			.filter[p | !p.eAllContents
		  					.filter(PragmaAnnotation)
		  					.filter[content.exists[it.contains("spec")]]
		  					.isEmpty
		  	]
		  	.head
	}
	
	def static extractInitImpl(GecosSourceFile s) {
		s.symbols
			.filter(ProcedureSymbol)
			.filter[name.startsWith("init_")]
			.filter[p | !p.eAllContents
		  					.filter(PragmaAnnotation)
		  					.filter[content.exists[it.contains("impl")]]
		  					.isEmpty
		  	]
		  	.head
	}
	
	def static extractNextImpl(GecosSourceFile s) {
		s.symbols
			.filter(ProcedureSymbol)
			.filter[name.startsWith("next_")]
			.filter[p | !p.eAllContents
		  					.filter(PragmaAnnotation)
		  					.filter[content.exists[it.contains("impl")]]
		  					.isEmpty
		  	]
		  	.head
	}

}
