macroScript Scatter_Branches
category:"Lab Nature"
tooltip: "Scater Branches"
icon:#("LabNature", 3)
(
	global scatterBranches
	global Rama = ""
	global factor = 1
	global NivelActual = 0
	global itemArray = #() --VARIABLE CON LOS ITEMS DEL LISTBOX
	global objeto_sel = "empty" as string
	global tronco = "" as string
	global tronco1 = "" as string
	global coincidencia = 0
	global vertZArray = #{}  
	global VerticesAltos = #{}
	global arr = #() as array
	global PosicionOriginal = [0,0,0]
	obj = ""
	objeto = ""

	struct estructura
	(
		function analisis Tronco = ( 	
			gc light:false delayed:false --GARBAGE COLLECTION POR SI HAY ÁRBOLES BORRADOS
			MeshSmoothLevel = Tronco.MeshSmooth.iterations
			if MeshSmoothLevel !=3 then Tronco.MeshSmooth.iterations = 3 --SETEAMOS EL NIVEL DE MESHSMOOTH DEL TRONCO EN 3 SI ES QUE NO LO TENÍA
			PosicionOriginal = Tronco.pos in coordsys world 
			Tronco.pos = [0,0,68.57] in coordsys world 
			EditPoly=(EditPolyMod())
			addModifier Tronco (EditPolyMod())
			RamaZstart = random 0.30 0.33
			CantidadTotalCarasTronco= polyop.getNumFaces Tronco
			select Tronco
			max modify mode
			subObjectLevel = 1
			sumaX = 0
			sumaY= 0
			PolyToolsSelect.Distance 99.7 --SELECCIONA VÉRTICES ALTOS
			VerticesAltos = Tronco.Edit_Poly.GetSelection  #Vertex
			VerticesAltos1 = VerticesAltos as array --CONVIERTE EL BITARRAY EN ARRAY
			for V = 1 to VerticesAltos1.count do --ANALIZA LOS VÉRTICES ALTOS PARA CALUCULAR ALTURA DEL TRONCO
			(
				VertexPos = polyop.getVert Tronco VerticesAltos1[V] --EXTRAE XYZ DE LOS VÉRTICES ALTOS
				append vertZArray VertexPos.z --AGRUPA VALORES EN Z DE ESOS VÉRTICES
				sumaX = sumaX + VertexPos.x --SUMA VALOR EN XY DE LAS CARAS MÁS ALTAS
				sumaY = sumaY + VertexPos.y
			)
			UltimoNivelPosX = sumaX/VerticesAltos1.count --DEFINE POSICIÓN EN XY DEL ÚLTIMO NIVEL
			UltimoNivelPosY = sumaY/VerticesAltos1.count
			VerticesAltos1 = #{}
			LargoTronco = vertZArray.count --ENCUENTRA EL MÁS ALTO
			max create mode
			
			InicioRamas = RamaZstart*LargoTronco
			cantidadNiveles = ((LargoTronco - RamaZstart*LargoTronco)/260) as integer 
			global AlturaXNivel = (LargoTronco - RamaZstart*LargoTronco)/cantidadNiveles 
			progressStart "Distributing branches"
			setProgressCancel False
			for i = 1 to CantidadTotalCarasTronco do --ANALIZA TODAS LAS CARAS DEL TRONCO
				(
					loc = polyop.getFaceCenter Tronco i  in coordsys world  --OBTIENE EL XYZ DE CADA CARA
					arr[i] = loc
				)
			for NivelActual = 1 to cantidadNiveles do ( --LOOPEA CADA NIVEL DE RAMAS  
				if NivelActual == 1 then (
					RamaxNivel = 7 --NIVEL 1 SIEMPRE TIENE 7 RAMAS
					CentroX = UltimoNivelPosX --ASIGNA POSICION EN XY DEL ULTIMO NIVEL
					CentroY = UltimoNivelPosY
				) else ( --DEFINE CANT. DE RAMAS POR NIVEL SI 6 o SI 7
					RamaxNivel = random 6 7
				)
				global rotain = random 0.0 360.0 --RANDOMIZA LA ROTACIÓN EN Z DE LA RAMAS PARA Q CADA NIVEL ARRANQUEN AL AZAR
				PorcentajeNivelActual = NivelActual/(cantidadNiveles) as float --DEFINE EN QUÉ PORCENTAJE DE CREACIÓN DE NIVEL ESTAMOS ACTUALMENTE	
				ScaleFactor = -PorcentajeNivelActual+1.1
				PosZNivel = ((-0.7667*PorcentajeNivelActual^2 + 1.7567*PorcentajeNivelActual)*(LargoTronco-InicioRamas)+InicioRamas)
--								A POLINOMIO EN EL QUE X ES (NIVEL ACTUAL/CANTIDAD DE NIVELES) * SECTOR A CUBRIR DE RAMAS + LUGAR DE INICIO DE RAMAS
				max modify mode
				faceArray = #()
				sumaX= 0
				sumaY= 0
				for i = 1 to CantidadTotalCarasTronco do --ANALIZA TODAS LAS CARAS DEL TRONCO
				(
					if arr[i].z> (PosZNivel*0.97) and arr[i].z< (PosZNivel*1.02) then --FILTRA LAS CARAS QUE ESTÉN APROX. EN EL NIVEL ACTUAL
					(
						append faceArray i --LAS AGREGA A UN ARRAY
						sumaX = sumaX + arr[i].x --SUMA VALOR EN XY DE TODO EL LOOP DE CARAS
						sumaY = sumaY + arr[i].y
					)
				)
				CantCarasSelected = faceArray.count --OBTIENE EL TOTAL DE CARAS DEL LOOP
				CentroX = sumaX/CantCarasSelected --SACA PROMEDIO PARA OBTENER EL CENTRO EN XY DEL TRONCO A UN Z DADO
				CentroY = sumaY/CantCarasSelected					
				subObjectLevel = 4
				PolyToolsSelect.Distance 0
				Tronco.Edit_Poly.SetOperation #FlipFace  
				subObjectLevel = 0
				max create mode
				for index_rama = 1 to RamaxNivel do ( --LOOPEA 6 o 7 VECES POR NIVEL
				--	gc light:false delayed:false
					estructura.seleccionar objeto LargoTronco InicioRamas index_rama NivelActual RamaxNivel ScaleFactor PosZNivel CentroX CentroY UltimoNivelPosX UltimoNivelPosY PorcentajeNivelActual--ELIGE UN OBJETO PARA REEMPLAZAR Y LO REEMPLAZA
				)
				porcentaje = 100.0*NivelActual/cantidadNiveles
				progressUpdate porcentaje
				cancelar = ""
				cancelar = getProgressCancel()
				if cancelar == true then exit 
			)
			deleteModifier Tronco 1
			max create mode
			progressEnd()
		),		
		function seleccionar objeto LargoTronco InicioRamas index_rama NivelActual RamaxNivel ScaleFactor PosZNivel CentroX CentroY UltimoNivelPosX UltimoNivelPosY PorcentajeNivelActual= ( 
			indice = itemArray.count --DEFINIMOS LARGO DE INDICE (CANT. OBJ. SELECCIONADOS)
			azar = random 1 indice as string --HACE UN RANDOM ENTRE 1 Y LA CANT. DE OBJ. SELECCIONADOS
			execute ("global objeto_sel" + "=" + "itemArray" + "[" + azar + "]") --ASIGNAMOS OBJETO_SEL EL OBJETO RANDOM
			obj = getnodebyname objeto_sel --NOS DEVUELVE EL VERDADERO NOMBRE DEL OBJETO
			global Rama = copy obj --COPIAMOS EL OBJETO SELECCIONADO POR EL RANDOM
			estructura.acomodar Rama LargoTronco InicioRamas index_rama NivelActual RamaxNivel ScaleFactor PosZNivel CentroX CentroY UltimoNivelPosX UltimoNivelPosY PorcentajeNivelActual--ACOMODA CADA RAMA
		),
		function acomodar Rama LargoTronco InicioRamas index_rama NivelActual RamaxNivel ScaleFactor PosZNivel CentroX CentroY UltimoNivelPosX UltimoNivelPosY PorcentajeNivelActual= (
			TroncoPos = Tronco.position
			Rama.position = TroncoPos
			rotate Rama 180 x_axis				
			
			RandomBendAngle = random 40.0 50.0
			RamaBend = Bend angle: RandomBendAngle direction: 90 axis: 1 
			in coordsys local RamaBend.gizmo.position = [0,40,0]
			addModifier Rama RamaBend

			rotate Rama -90 y_axis
			if 	RamaxNivel == 7 then RamaZrot = random 10 11 --NIVEL DE 7 RAMAS--> VALORES  ENTRE 40-45-50-55º
			if 	RamaxNivel == 6 then RamaZrot = random 12 13 --NIVEL DE 6 RAMAS--> VALORES  ENTRE 55-60-65-70º
			global rotain = rotain + RamaZrot*5 --ACUMULA VALORES INCREMENTALES RESPECTO DE LA ANTERIOR
			rotate Rama rotain z_axis --ROTA A LA RAMA EN Z	
			
			if PorcentajeNivelActual == 1 then ( --SI ESTAMOS EN EL ULTIMO NIVEL
				CentroX = UltimoNivelPosX --ASIGNAMOS POSICIÓN XY A LAS RAMAS IGUAL AL VÉRTICE SUPERIOR
				CentroY = UltimoNivelPosY
			)
			AlturaRandom = random -20 18
			Rama.pos.z = (PosZNivel + AlturaRandom) --ACOMODA LA RAMA EN Z SEGUN NIVEL Y CON RANDOM
			Rama.pos.x = CentroX --CENTRA LA RAMA EN EL TRONCO SI ESTE NO ES RECTO
			Rama.pos.y = CentroY
			rayo = ray Rama.position Rama.dir
			distancia = intersectRay Tronco rayo --MIDE LA DISTANCIA DEL CENTRO DEL TRONCO A LA CORTEZA
			if distancia != undefined then (
				offsetX = (CentroX - distancia.pos.x)*0.4
				offsetY = (CentroY - distancia.pos.y)*0.4
				move Rama [-offsetX,-offsetY,0]  --ACOMODA LA RAMA CON RESPECTO A CUAN METIDA ESTÁ EN EL TRONCO 
			) 
			
			RamaXrotate = random 40 50
			in coordsys local rotate Rama -(RamaXrotate+20*PorcentajeNivelActual) x_axis 
			ScaleRandom = random  0.95 1.00 --RANDOMIZA EL ACHICAMIENTO
 			scale Rama [ScaleFactor*ScaleRandom,ScaleFactor*ScaleRandom,ScaleFactor*ScaleRandom] --ACHICA LAS RAMAS POR NIVEL
			
			Rama.parent = Tronco
			Rama.name ="Rama" + index_rama as string + "Nivel" + NivelActual as string 
		)
	)--FIN DE ESTRUCTURA
	
	
	---COMIENZA LA PARTE DE GUI
	rollout RamasRollout "Branches" width:161 height:334
	(
		--CREAMOS OBJETOS DE LA GUI
		listbox selecc "" pos:[9,53] width:143 height:8
		pickbutton pick "Pick Objects" pos:[10,7] width:75 height:28
		button remove "Remove" pos:[11,168] width:64 height:22
		button clearbtn "Clear" pos:[94,168] width:56 height:22
		label lbl1 "Branches to be scattered:" pos:[11,38] width:139 height:16
		button add_btn "Add" pos:[101,7] width:49 height:25
		on pick picked obj do --CUANDO PICKAMOS OBJETO VARIABLE OBJ PARA LO PICKADO
		( 
			arraystring = obj.name as string --CONVERTIMOS EL OBJETO SELECCIONADO EN NOMBRE Y VA A ARRAYSTRING
			appendIfUnique itemArray arraystring --AGREGA EL OBJETO SI NO ESTÁ
			selecc.items = itemArray --ACTUALIZA LISTBOX
			global coincidencia = finditem itemArray tronco1 --BUSCA QUE EL TERRENO NO COINCIDA CON UN OBJETO
		)
		
		on add_btn pressed do --CUANDO PICKAMOS OBJETO VARIABLE OBJ PARA LO PICKADO
		( 
			fn filtro obj =(
				if superclassof obj == GeometryClass or superclassof obj == shape then (
					existe = findItem itemArray obj.name --BUSCA SI EL OBJETO NO ESTÁ YA INCLUÍDO
					if existe == 0 then ( --SI NO ESTÁ EL OBJETO YA INCLUÍDO
						true --LO MUESTRA
					)else( --SI YA ESTABA INCLUÍDO
						false --NO LO MUESTRA
					)
				)else ( --SI NO ES GEOMETRÍA O SHAPE
					false --NO LO MUESTRA
				)
			)
			
			listaSeleccionada = selectByName title: "Branches to be scattered along the trunk" buttonText: "Add" filter:filtro  showHidden:False single:False
			if  listaSeleccionada !=undefined then 
			(
				for item = 1 to listaSeleccionada.count do 
				(
					arraystring = listaSeleccionada[item].name as string
					appendIfUnique itemArray arraystring
				)
				selecc.items = itemArray --ACTUALIZA LISTBOX
			)
		)
		
		on remove pressed do --CUANDO APRETAMOS REMOVER
		(
			if itemArray.count != 0 then  --BORRA SOLO SI HAY QUÉ BORRAR
			(
				borrar = selecc.selection --EN VARIABLE BORRAR INSERTAMOS LO SELECCIONADO EN EL LISTBOX ACTUALMENTE
				deleteItem itemArray borrar --BORRAMOS EL ITEM
				selecc.items = itemArray --ACTUALIZA LISTBOX
				global coincidencia = finditem itemArray terreno1 --BUSCA QUE EL TERRENO NO COINCIDA CON UN OBJETO
			)
		)
		
		on clearbtn pressed do
		(
			for item = 1 to itemArray.count do (
			borrarla = deleteItem itemArray 1 --BORRA ITEM 1 DEL LISTBOX LA CANTIDAD DE VECES HASTA VACIARA
			)
			selecc.items = itemArray --ACTUALIZA LISTBOX
		)
	)
	
	rollout TroncoRollout "Trunk" width:161 height:165
	(
		GroupBox grp2 "Trunk" pos:[6,7] width:147 height:39
		pickbutton picktrunk "Pick Trunk" pos:[43,58] width:75 height:28
		label lbl_trunk "<no objects>" pos:[16,24] width:121 height:19

		on picktrunk picked terr do --CUANDO PICKAMOS UN TERRENO VARIABLE TERR PARA LO PICKADO
		(	
			global tronco1 = terr.name --CONVERTIMOS EL OBJETO SELECCIONADO EN NOMBRE Y VA A ARRAYSTRING
			lbl_trunk.caption = tronco1 --CAMBIAMOS LA IMPRESIÓN EN EL MENU
			global Tronco = getnodebyname tronco1
			global coincidencia = finditem itemArray tronco1 --BUSCA QUE EL TERRENO NO COINCIDA CON UN OBJETO
		)
	)
	
	rollout FinalRollout "Execute" width:162 height:128
	(
		GroupBox grp1 "Messages" pos:[6,8] width:147 height:50
		label lbl_message "" pos:[11,23] width:139 height:24
		button start "Start Copying" pos:[70,63] width:82 height:28 toolTip:""
		
		on FinalRollout open do global scatterBranches = "open" --VARIABLE PARA NO ABRIR 2 VECES LA VENTANA
		on FinalRollout close do global scatterBranches = undefined
			
		on start pressed do --CUANDO APRETAMOS EL BOTÓN START
		(
			if itemArray.count != 0 then --SI HAY OBJETOS SELECCIONADOS
			(
				if tronco1 != "" then--SI HAY UN TRONCO SELECCIONADO
				(
					if coincidencia == 0 then --SI NO HAY COINCIDENCIA
					(
						lbl_message.caption = "" --SIN ERRORES
						estructura.analisis Tronco--ANALIZA EL TRONCO Y CREA VARIABLES PARA LA DISTRIBUCIÓN DE RAMAS
						Tronco.pos = PosicionOriginal in coordsys world
						RamasRollout.selecc.items = itemArray --ACTUALIZA LISTBOX Y LO BORRA
						faceArray = #{}
						vertZArray = #{}
					) else (
						lbl_message.caption = "The trunk is the same as one of the branches."
					)
				) else (
					lbl_message.caption = "Please, select a trunk."
				)
			) else (
				lbl_message.caption = "Please, select a branch at least."
			)
		)
	)
	
	if scatterBranches != "open" then (
		Window = newRolloutFloater "Scater Branches" 170 470 950 250 
		addRollout RamasRollout Window
		addRollout TroncoRollout Window
		addRollout FinalRollout Window
	)
)