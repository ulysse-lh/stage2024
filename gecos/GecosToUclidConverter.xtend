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
			val pstr = new PrintStream(new File(outPath+ File.separator+  procedure.containingProject.name +"_"+ procedure.symbolName+ ".ucl"))
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
		//i.class.simpleName + "[" + i.listChildren.map[convertInstr] + "]"
		if (i.type instanceof ACIntType) {
			val bv = i.type as ACIntType
			
			if (i.listChildren.length != 1)
				throw new Exception("Only constants are supported for ac_int.\nE.g., use"+
									"abool ? (ap_int<2>)0 : (ap_int<2>)3\nrather than\n"+
									"(ap_int<2>)(abool ? 0 : 3)"
				)
			
			return convertInstr(i.listChildren.first) + "bv" + bv.bitwidth
		}
		"// No equivalent to casting in UCLID!"
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
			call.address.convertInstr + "(" + call.args.toString(",") + ")"
		} else if (psym.procedure !== null) { 
			if (psym.functionType.returnType instanceof VoidType) {
				return "call " + call.address.convertInstr + "(" + call.args.toString(",") + ")"
			} else {
				throw new UnsupportedOperationException("Internal calls not supported " + call);
			}
		} else {
			if (psym.name=="printf") null
			else call.address.convertInstr + "(" + call.args.toString(",") + ")"
		}
	}

	def static dispatch String convertInstr(SetInstruction i) {
		val src = i.source
		if (src instanceof CallInstruction) {
			val psym = src.procedureSymbol
			if (psym.procedure !== null && !psym.uninterpreted) {
				if (!(psym.functionType.returnType instanceof VoidType)) {
					return "call (" + i.dest.convertInstr + ") = " + src.address.convertInstr + "(" +
						src.args.toString(",") + ")"
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
				"if (" + convertInstr(i.children.get(0)) + ") then " + convertInstr(i.children.get(1)) + " else " + convertInstr(i.children.get(2)) 
			case "and":
				"(" + convertInstr(i.children.get(0)) + " & " + convertInstr(i.children.get(1)) + ")"
			case "or":
				"(" + convertInstr(i.children.get(0)) + " | " + convertInstr(i.children.get(1)) + ")"
			case "land":
				"(" + convertInstr(i.children.get(0)) + " && " + convertInstr(i.children.get(1)) + ")"
			case "lor":
				"(" +convertInstr(i.children.get(0)) + " || " + convertInstr(i.children.get(1)) + ")"
			default: {
				i.name + "(" + i.children.map[convertInstr].reduce[p1, p2|p1+ "," +p2]+ ")"
			}
		}

	}

	def static dispatch String convertInstr(RetInstruction i) {
		if(i.expr === null) return "" else "ret_" + currentProc.symbolName + "=" + i.expr.convertInstr
	}

	def static dispatch String convertInstr(SimpleArrayInstruction i) {
		correctIdentifier(i.symbolName) + "[" + i.index.head.convertInstr + "]"
	}

	def static dispatch String convertBlock(Block b) {
		"// unsuported for " + b
	// throw new UnsupportedOperationException("TODO: auto-generated method stub for "+b)
	}

	def static dispatch String convertBlock(BasicBlock bb) {
		if (bb.instructionCount !== 0)
			bb.instructions.map[convertInstr].filterNull.reduce[a, b|a + ";\n" + b] + ";"
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
		'''
			if («convertInstr((b.testBlock as BasicBlock).instructions.head)») {	
				«convertBlock(b.thenBlock)» 
			} «if (b.elseBlock!==null) {
			'''
			else {
				«convertBlock(b.elseBlock)»
			}
			'''
			} else {
			""
		}»
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

	def static dispatch String convertBlock(DoWhileBlock b) {
		'''
			{
				«convertBlock(b.bodyBlock)»
			}
			while («convertInstr((b.testBlock as BasicBlock).instructions.head)») {
				«convertBlock(b.bodyBlock)»
			}
		'''
	}

	def static dispatch String convertBlock(WhileBlock b) {
		'''
			while («convertInstr((b.testBlock as BasicBlock).instructions.head)») {
				«convertBlock(b.bodyBlock)»
			}
		'''
	}

	def static isUninterpreted(ProcedureSymbol psym) {
		val uclidPragma = psym.eAllContents.filter(PragmaAnnotation).filter[content.exists[it.contains("uclid")]].toList
		for(p :uclidPragma)
			if (p.content.exists[it.contains("uninterpreted")]) return true
		
		return false	
					
	}

	def static convert(Procedure proc) {
		val locals = EMFUtils.eAllContentsInstancesOf(proc.body, Symbol) + proc.listParameters;
		val refs = EMFUtils.eAllContentsInstancesOf(proc.body, ISymbolUse);
		val extRefs = refs.reject[locals.contains(usedSymbol)].map[usedSymbol].reject(ProcedureSymbol).toSet
		val funType = proc.symbol.type as FunctionType
		val argsDecl = proc.listParameters.map[correctIdentifier(it.name) + ":" + typeName(it.type)]

		currentProc = proc
		val body = '''
			{
				«FOR s:EMFUtils.eAllContentsInstancesOf(proc.body, Symbol).reject(ProcedureSymbol)»
				«declare(s)»
				«ENDFOR»
				«convertBlock(proc.body)»
			}
		'''

		val sideffects = if(extRefs.empty) "" else '''modifies «extRefs.map[it.name].toString(",")»;'''
		return '''
			procedure «proc.symbol.name»(«argsDecl.toString(",")») «if (!(funType.returnType instanceof VoidType)) {'''returns ( ret_«proc.symbolName» : «typeName(funType.returnType)») 
			'''
		} else {
			""
		}»«sideffects» 
			«body»
		''';
	}

	def static dispatch String typeName(Type type) {
		System.out.println(type+"; "+type.class)
		"//Unsupported type " + type//throw new UnsupportedOperationException("Unsupported typeName() for " + type)
	}
	
	def static dispatch String typeName(VoidType type) {
		"void"
	}
	
	def static dispatch String typeName(AliasType type) {
		type.name
	}
	
	def static dispatch String typeName(ACIntTypeImpl type) {
		if (type.getOverflowMode != OverflowMode.AC_WRAP)
			System.err.println("Warning: UCLID supports only wrapping upon overflow. Defaulting to AC_WRAP")
		
		"bv" + type.bitSize
	}
	

	def static dispatch String typeName(IntegerType type) {
		"integer"
	}

	def static dispatch String typeName(BoolType type) {
		"boolean"
	}

	def static dispatch String typeName(PtrType s) {
		'''ptr_«s.base.typeName»'''
	}

	def static dispatch String typeName(ArrayType s) {
		'''array_«s.hashCode»'''
	}

	def static dispatch String typeName(RecordType type) {
		type.name
	}

	def static dispatch String typeName(EnumType type) {
		type.name
	}

	def static dispatch declareType(Type s) {
		"//Unsupported type " + s//throw new UnsupportedOperationException("TODO: auto-generated method stub fir " + s)
	}
	
	def static dispatch declareType(VoidType s) {
		""
	}
	
	def static dispatch declareType(AliasType t) {
		
		'''type «t.name» = «typeName(t.alias)»;'''
	}

	def static dispatch declareType(PtrType s) {
		'''type ptr_«s.base.typeName» = integer;'''
	}

	def static dispatch declareType(RecordType s) {
		'''
			type «s.name» = record {
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
		'''type «s.name» = enum {«s.enumerators.map[name].toString(",")» };'''
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
			if (!(returnType instanceof VoidType)) {
				'''function «s.name»(«args.toString(",")») : «typeName(returnType)»;'''
			}
		} else {
			convert(s.procedure)
		}
	}

	def static dispatch declare(Symbol s) {
		'''var «s.name» : «typeName(s.type)»;'''
	}


	def static extractInvariants(GecosSourceFile pset) {
		val str = new StringBuffer
		val pragmas =  pset.eAllContents.filter(PragmaAnnotation).toIterable
		for (p:pragmas) {
			val invs =  p.content.filter[it.contains("uclid::invariant")]
			for (inv: invs) {
				str.append(inv.replace("uclid::", "")+";\n")
			}	
		}
		str.toString
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
		'''
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
				«s.declare»
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
		'''
	}
	
	def static correctIdentifier(String s) {
		val reserved = #["in", "out"]
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
	
	enum State {
		NOT_FOUND, INIT_LABEL_FOUND, INIT_FOUND, LOOP_FOUND, NEXT_LABEL_FOUND, NEXT_FOUND
	}
	
	static class BlockOrInstr {
		Block b;
		Instruction i;
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
						_finished123 = true;
					}
					if (!_finished123) {
						«convertBlock(whyle.bodyBlock)»
					}
			'''
		} else if (initBlock instanceof DoWhileBlock) {
			val whyle = initBlock as DoWhileBlock
		
			'''
					if (!(«convertInstr((whyle.testBlock as BasicBlock).instructions.head)»)) {
						_finished123 = true;
					}
					if (!_finished123) {
						«convertBlock(whyle.bodyBlock)»
					}
			'''
		} else throw new RuntimeException("Expected while")
		
	}
	


}