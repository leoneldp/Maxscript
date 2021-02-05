macroScript Pine_animator
category:"Lab Nature"
tooltip: "Pine Animator"
icon:#("LabNature", 4)
(
	global pineAnimator
	global BranchesStrength = 0.7
	global BranchesFreq = 3.0
	global TwigsStrength = 1.0
	global TwigsFreq = 7.0
	global Twig = true
	global RamasSeleccionadas = #{}
	
	function animar Twig = (
		undo on
		(
			NombresRamita = #{} as array --DECLARA LA ARRAY DONDE GUARDAN LOS NOMRES DE CADA RAMITA
			progressStart "Applying animation"
			setProgressCancel False		
			if Twig == true then ( --SI EL CHECKBOX ESTÁ ACTIVADO
				for RamaNum = 1 to RamasSeleccionadas.count do --HACE UN PASO POR CADA RAMA DEL PINO
				(
					select RamasSeleccionadas[RamaNum]
					max modify mode
					convertTo RamasSeleccionadas[RamaNum] PolyMeshObject
					setSelectionLevel  $ #face
					for RamitaNum = 1 to 23 do --HACE UN PASO POR CADA RAMITA DE CADA RAMA
					(
						$.EditablePoly.selectByMaterial (RamitaNum*2) --SELECCIONA EL TALLO
						$.EditablePoly.selectByMaterial ((RamitaNum*2)+1) clearCurrentSelection: False --SELECCIONA LAS HOJAS
						CarasRamita = $.EditablePoly.GetSelection  #Face --OBTIENE LAS CARAS SELECCIONADAS
						NombresRamita[RamitaNum] = ($.name + "Ramita" + RamitaNum as string) as string --DESIGNA NOMBRE DEL OBJETO A DETACHAR, EJ: "RAMITA1"
						polyop.detachFaces $ CarasRamita asNode: True name: NombresRamita[RamitaNum] --HACE EL DETACTCH DE LA RAMITA
						execute ("VertexPos = polyop.getVert" + "$" + NombresRamita[RamitaNum] + " 10") --OBTIENE EL VERTEX PARA EL PIVOT DE LA RAMITA
						execute ("$" + NombresRamita[RamitaNum] + ".pivot = VertexPos") --ESTABLECE EL PIVOT DE LA RAMITA
						execute ("$" + NombresRamita[RamitaNum] + ".parent = $") --ESTABLECE EL TALLO COMO PARENT DE LA RAMITA
					)--FIN DEL FOR DETATCH POR RAMITA
					max create mode 
					clearSelection()
					
					for ax = 1 to NombresRamita.count do 
					(
						execute ("selectMore  $" + NombresRamita[ax])--SELECCIONAMOS LAS RAMITAS RECIENTEMENTE CREADAS
					)
					objetos_selecc= selection as array --GUARDAMOS SELECCIÓN RAMITAS EN VARIABLE
					for itemNum = 1 to objetos_selecc.count do --HACE UN PASO POR CADA RAMITA PARA DARLE MOVIM.
					(
						c = rotation_list ()
						objetos_selecc[itemNum].rotation.controller  = c
						d = Noise_Rotation ()
						d.noise_strength = [(TwigsStrength/10),(TwigsStrength/10),(TwigsStrength/10)]
						d.seed = random 1 1000
						d.frequency = TwigsFreq/100
						d.fractal = false
						objetos_selecc[itemNum].rotation.controller.Available.controller = d
						objetos_selecc[itemNum].rotation.controller.setName 2 "AutoAnimated"
					)--FIN DEL FOR ANIM POR RAMITA
					
					porcentaje = 100.0*RamaNum/RamasSeleccionadas.count --ANTES DE TERMINAR CADA RAMA ACTUALIZAMOS EL %
					progressUpdate porcentaje
					cancelar = ""
					cancelar =getProgressCancel()
					if cancelar == true then exit	
				) --FIN DEL FOR POR RAMA
			)
			
			select RamasSeleccionadas
			for itemNum = 1 to RamasSeleccionadas.count do --APLICA EL NOISE CONTROLLER A CADA RAMA (MÁS SUAVE)
			(
				c = rotation_list ()
				RamasSeleccionadas[itemNum].rotation.controller  = c
				d = Noise_Rotation ()
				d.noise_strength = [BranchesStrength/10,BranchesStrength/10,BranchesStrength/10]
				d.seed = random 1 1000
				d.frequency = BranchesFreq/100
				d.fractal = false
				RamasSeleccionadas[itemNum].rotation.controller.Available.controller = d
				RamasSeleccionadas[itemNum].rotation.controller.setName 2 "AutoAnimated"
			)
		)
		progressEnd()
	)
	
		---COMIENZA LA PARTE DE GUI
	rollout parametros "Parameters" width:162 height:350
	(
		GroupBox grpBranches "Branches" pos:[6,3] width:147 height:61
		spinner spnBranches_Strenght "" pos:[80,16] width:58 height:16 range:[0,50,0] type:#float
		spinner spnsBranches_Frequency "" pos:[80,37] width:58 height:16 range:[0,100,0] type:#float
		label lbl1 "Strenght:" pos:[33,17] width:48 height:16
		label lbl2 "Frequency:" pos:[24,38] width:55 height:16
		
		GroupBox grpTwigs "Twigs" pos:[6,69] width:147 height:62
		spinner spnTwigs_Strenght "" pos:[80,87] width:58 height:16 range:[0,50,0] type:#float
		spinner spnsTwigs_Frequency "" pos:[80,107] width:58 height:16 range:[0,100,0] type:#float
		label lbl3 "Strenght:" pos:[33,88] width:48 height:16
		label lbl4 "Frequency:" pos:[24,108] width:55 height:16
				
		checkbox chkTwig "Animate Twigs" pos:[9,141] width:106 height:16 checked: True
		
		on parametros open do
		(
			spnBranches_Strenght.value =  BranchesStrength
			spnsBranches_Frequency.value = BranchesFreq
			spnTwigs_Strenght.value = TwigsStrength
			spnsTwigs_Frequency.value = TwigsFreq
		)
		on spnBranches_Strenght changed leo do BranchesStrength = spnBranches_Strenght.value
		on spnsBranches_Frequency changed leo do BranchesFreq = spnsBranches_Frequency.value
		on spnTwigs_Strenght changed leo do TwigsStrength = spnTwigs_Strenght.value
		on spnsTwigs_Frequency changed leo do TwigsFreq = spnsTwigs_Frequency.value
			
		on chkTwig changed Twig do (
			if Twig == true then
			(
				global Twig = true
			) else (
				global Twig = false
			)
		)
	)
	
	rollout final "Execute" width:162 height:161
	(
		GroupBox grp1 "Messages" pos:[6,8] width:147 height:50
		label lbl_message "" pos:[11,23] width:139 height:24
		button start "Apply Animation" pos:[40,63] width:90 height:28 toolTip:""
		button removeAnim "Remove Animation" pos:[35,101] width:100 height:28 toolTip:""
		
		on final open do global pineAnimator = "open" --VARIABLE PARA NO ABRIR 2 VECES LA VENTANA
		on final close do global pineAnimator = undefined
			
		on start pressed do (--CUANDO APRETAMOS EL BOTÓN APPLY ANIMATION
			RamasSeleccionadas = selection as array
			if RamasSeleccionadas.count != 0 then (
				lbl_message.caption = "" --SIN ERRORES
				animar Twig
			) else (
				lbl_message.caption = "Please select some branches."
			)
		)--FIN BOTON
		
		on removeAnim pressed do ( --CUANDO APRETAMOS EL BOTÓN REMOVE ANIMATION
			progressStart "Removing animation" 
			for i = 1 to selection.count do (
				selection[i].rotation.controller= Euler_XYZ ()
	--			porcentaje = 100.0*itemNum/pastos_Sel.count --ANTES DE TERMINAR CADA BRIZNA ACTUALIZAMOS EL %
	--			progressUpdate porcentaje
			)
			progressEnd()
		)--FIN BOTÓN
	)
	
	if pineAnimator != "open" then (
		Window = newRolloutFloater "Pine Animator" 170 353 1050 325
		addRollout parametros Window
		addRollout final Window
	)
 )
