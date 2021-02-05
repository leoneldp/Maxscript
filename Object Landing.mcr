macroScript object_landing
category:"Lab Nature"
tooltip: "Object Landing"
icon:#("LabNature", 7)

(
	global objectLanding 
	global itemArray = #() --VARIABLE CON LOS ITEMS DEL LISTBOX
	global objeto_sel = "empty" as string
	global Terreno = "" as string
	global terreno1 = "" as string
	global coincidencia = 0
	global ZOffset = 0
	
	struct estructura
	(
		function place Terreno itemArray ZOffset = (
			undo on
			(
				for i = 1 to itemArray.count do
				(
					obj = getnodebyname itemArray[i]					
					r = ray obj.pos [0,0,-1]
					r1= ray obj.pos [0,0,1]
					interseccion = intersectRay Terreno r
					if interseccion== undefined then 
					(
						MyNormal = normalModifier flip:true
 						addModifier Terreno MyNormal					
						interseccion = intersectRay Terreno r1
					)
					if interseccion != undefined then obj.pos = interseccion.pos + [0,0,ZOffset]
					if MyNormal != undefined then deleteModifier Terreno 1
				)
			)
		)
	)

		---COMIENZA LA PARTE DE GUI
	rollout ObjetosRollout "Objects" width:161 height:334
	(
		--CREAMOS OBJETOS DE LA GUI
		listbox selecc "" pos:[9,53] width:143 height:6
		pickbutton pick "Pick Objects" pos:[10,7] width:75 height:28
		button remove "Remove" pos:[11,140] width:64 height:22
		button clearbtn "Clear" pos:[94,140] width:56 height:22
		label lbl1 "Objects to be landed:" pos:[11,38] width:139 height:16
		button add_btn "Add" pos:[101,7] width:49 height:25
		on pick picked obj do --CUANDO PICKAMOS OBJETO VARIABLE OBJ PARA LO PICKADO
		( 
			arraystring = obj.name as string --CONVERTIMOS EL OBJETO SELECCIONADO EN NOMBRE Y VA A ARRAYSTRING
			appendIfUnique itemArray arraystring --AGREGA EL OBJETO SI NO ESTÁ
			selecc.items = itemArray --ACTUALIZA LISTBOX
			global coincidencia = finditem itemArray tereno1 --BUSCA QUE EL TERRENO NO COINCIDA CON UN OBJETO
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
			
			listaSeleccionada = selectByName title: "Objects to be landed" buttonText: "Add" filter:filtro  showHidden:False single:False
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
	
	rollout TerrenoRollout "Terrain" width:161 height:165
	(
		GroupBox grp2 "Terrain" pos:[6,7] width:147 height:39
		pickbutton pickterrain "Pick Terrain" pos:[43,53] width:75 height:28
		label lbl_terrain "<no objects>" pos:[16,24] width:121 height:19
		GroupBox grpOffset "Offset" pos:[6,88] width:147 height:39
		spinner spnZOffset "" pos:[85,103] width:63 height:16 range:[-99999,99999,0] type:#float
		label lblOffset "Z Offset:" pos:[40,104] width:47 height:16

		on pickterrain picked terr do --CUANDO PICKAMOS UN TERRENO VARIABLE TERR PARA LO PICKADO
		(	
			global terreno1 = terr.name --CONVERTIMOS EL OBJETO SELECCIONADO EN NOMBRE Y VA A ARRAYSTRING
			lbl_terrain.caption = terreno1 --CAMBIAMOS LA IMPRESIÓN EN EL MENU
			global Terreno = getnodebyname terreno1
			global coincidencia = finditem itemArray terreno1 --BUSCA QUE EL TERRENO NO COINCIDA CON UN OBJETO
		)
		
		on TerrenoRollout open do --CUANDO SE ABRE EL ROLLOUT DEFINIMOS LOS VALORES DE LOS SPINNERS
		(
			spnZOffset.value = ZOffset
		)
		
		on spnZOffset changed leo do ZOffset = spnZOffset.value
		
	)
	
	rollout FinalRollout "Execute" width:162 height:128
	(
		GroupBox grp1 "Messages" pos:[6,8] width:147 height:50
		label lbl_message "" pos:[11,23] width:139 height:24
		button start "Land Object/s" pos:[70,63] width:82 height:28 toolTip:""
		
		on FinalRollout open do global objectLanding = "open" --VARIABLE PARA NO ABRIR 2 VECES LA VENTANA
		on FinalRollout close do global objectLanding = undefined
			
		on start pressed do --CUANDO APRETAMOS EL BOTÓN START
		(
			if itemArray.count != 0 then --SI HAY OBJETOS SELECCIONADOS
			(
				if Terreno != "" then--SI HAY UN TERRENO SELECCIONADO
				(
					if coincidencia == 0 then --SI NO HAY COINCIDENCIA
					(
						lbl_message.caption = "" --SIN ERRORES
						estructura.place Terreno itemArray ZOffset --ANALIZA EL TERRENO Y CREA VARIABLES PARA LA DISTRIBUCIÓN DE RAMAS
						
						ObjetosRollout.selecc.items = itemArray --ACTUALIZA LISTBOX Y LO BORRA
						
					) else (
						lbl_message.caption = "The terrain has the same as one of the objects."
					)
				) else (
					lbl_message.caption = "Please, select a terrain."
				)
			) else (
				lbl_message.caption = "Please, select at least an object."
			)
		)
	)
	

	if objectLanding != "open" then (
		Window = newRolloutFloater "Object Landing" 170 490 1250 475
		addRollout ObjetosRollout Window
		addRollout TerrenoRollout Window
		addRollout FinalRollout Window
	)
)
