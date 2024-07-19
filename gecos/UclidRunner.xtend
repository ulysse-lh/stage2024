package fr.irisa.cairn.gecos.model.hls.idg.codegen.lowering.uclid

import fr.irisa.cairn.gecos.model.hls.idg.codegen.idgtocdfg.SLPCodegen
import fr.irisa.cairn.gecos.model.hls.idg.transforms.SpeculativeLoopPipelining
import fr.irisa.cairn.gecos.model.hls.tests.programs.FileInputProgram
import fr.irisa.cairn.gecos.model.hls.tools.vivadohls.templates.CodegenUtils
import fr.irisa.cairn.gecos.model.hls.utils.CompilationOptions

class UclidRunner {

	
	def static void main(String[] args) {
		val compilationOptions = new CompilationOptions

		val tests = #[
	//		"./src-c/uclid/test0.cpp" -> "test0",
			//"./src-c/uclid/test1.cpp" -> "test1"
			"./src-c-gen/single_spec_3_5_0/spec_single_spec_3_5_0/single_spec.cpp" -> "single_spec"
			//"./src-c-gen/single_spec_3_5_0/spec_single_spec_3_5_0/fsm_x.cpp" -> "fsm_x"
		].map[new FileInputProgram(key, value)]
		
		for (src : tests) {
			val p = src.buildProject
			CodegenUtils.execCommand(#["rm", "-rf", "src-c-gen/*"])
			SLPCodegen.codegenForSimulation(src, p, "src-c-gen/golden_" + p.name, false, compilationOptions)
			CodegenUtils.execCommand(#["make", "-C", "src-c-gen/golden_" + p.name, "clean"])//, "compile"])
			
			CodegenUtils.execCommand(#["rm", "-rf","./src-c-gen/*"])
			SpeculativeLoopPipelining.preprocess(p, compilationOptions);

			GecosToUclidConverter.apply(p,"./src-c-gen/uclid/")

			CodegenUtils.execCommand(#["/home/ulysse/Documents/uclid/target/universal/uclid-0.9.5/bin/uclid", "-m", "./src-c-gen/uclid/" + p.name + "/main.ucl"])
		}

	}

}
