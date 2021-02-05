macroScript Nature_Replacement
category:"Lab Nature"
tooltip: "Nature Replacement"
icon:#("LabNature", 2)
(
	global natureReplacement
	global itemArray = #() --VARIABLE CON LOS ITEMS DEL LISTBOX
	global objeto_sel = "empty" as string
	global xypos = [0,0,0] as point3
	global reemplazo = "" as string
	global reemplazo1 = "" as string
	global coincidencia = 0
	global Zrot = 0
	global Xscal = 0
	global Yscal = 0
	global Zscal = 0
	global Noise_amount = 0
	global Noise_escala = 100
	global chkNoise_test = false
	global Bend_angle = 0
	global Bend_direction = 0
	global Bend_axis = 0
	global chkBend_test = false
	global Stretch_stretch = 0 as float
	global Stretch_amplify = 0
	global Iterations = 1
	global chkStretch_test = false
	global chkMeshsmooth_test = false
	global deg = false
	obj = ""
	objeto = ""
	
 	struct estructura
 	(
		function seleccionar objeto = ( 
			for objetosRestantes = 1 to itemArray.count do 
				(
					indice = itemArray.count --DEFINIMOS LARGO DE INDICE (CANT. OBJ. QUE FALTAN SER REEMPLAZADOS)
					convertido = indice as string
					execute ("global objeto_sel" + "=" + "itemArray" + "[1]") --ASIGNAMOS A OBJETO_SEL EL 1 DE LA ARRAY
					estructura.reemplazar objetoReemplazado --EJECUTAMOS LA FUNCIÓN PARA REEMPLAZAR EL OBJETO
					deleteItem itemArray 1 --BORRAMOS EL 1º OBJETO DE LA LISTA
				)
				
		),
		
		function reemplazar objetoReemplazado = (
			obj = getnodebyname objeto_sel --NOS DEVUELVE EL VERDADERO NOMBRE DEL OBJETO A SER REEMPLAZADO
			undo on	(
				select reemplazo --SELECCIONA EL REEMPLAZO
				objetoReemplazado = copy $ --COPIA EL REEMPLAZO
				objetoReemplazado.position = obj.position --UBICA EL OBJETO REEMPLAZADO EN EL LUGAR DEL VIEJOh
				objetoReemplazado.rotation.z_rotation = obj.rotation.z_rotation
				objetoReemplazado.rotation.y_rotation = obj.rotation.y_rotation
				objetoReemplazado.rotation.x_rotation = obj.rotation.x_rotation
				delete obj --ELIMINA EL OBJETO VIEJO 
			)
			estructura.variar objetoReemplazado --EJECUTAMOS LA FUNCIÓN PARA CAMBIAR ROTATION Y SCALE
		),
		
		function variar objetoReemplazado= (
			Xscale_variada = random -(Xscal) Xscal
			Yscale_variada = random -(Yscal) Yscal
			Zscale_variada = random -(Zscal) Zscal
			in coordsys local scale objetoReemplazado  [(1-(Xscale_variada/100)),(1-(Yscale_variada/100)),(1-(Zscale_variada/100))]
				
			rotacion_variada = random 0 Zrot
			rotate objetoReemplazado  rotacion_variada Z_axis
			estructura.modifiers objetoReemplazado
		),
		
		function modifiers objetoReemplazado= (
			if chkNoise_test == true then ( --SI ESTÁ ACTIVADO EL NOISE
				newSeed = random 0 9999
				newScale = random (Noise_escala*0.95) (Noise_escala*1.05)
				newAmount = random (Noise_amount*0.9) (Noise_amount*1.1)
				myNoise = NoiseModifier scale: newScale fractal:true strength:[newAmount,newAmount,newAmount] seed:newSeed
				addModifier objetoReemplazado myNoise
			)
			if chkBend_test == true then ( --SI ESTÁ ACTIVADO EL BEND
				newAngle = random -(Bend_angle) Bend_angle
				newDirection = random 0.0 Bend_direction
				myBend = BendMod angle: newAngle direction:newDirection axis: Bend_axis
				addModifier objetoReemplazado myBend
			)
			if chkStretch_test == true then ( --SI ESTÁ ACTIVADO EL STRETCH
				newStretch = random 0.0 Stretch_stretch as float
				newAmplify = random Stretch_amplify (Stretch_amplify*0.9)
				myStretch= Stretch Stretch: newStretch Amplify: newAmplify axis: 2
				addModifier objetoReemplazado myStretch
			)
			if chkMeshsmooth_test == true then (--SI ESTÁ ACTIVADO EL MESHSMOOTH
				myMeshsmooth = meshSmooth iterations:  Iterations
				addModifier objetoReemplazado myMeshsmooth
			)
		)
	)--FIN DE ESTRUCTURA

	
---COMIENZA LA PARTE DE GUI
	rollout objetos "Objects" width:161 height:334
	(
		--CREAMOS OBJETOS DE LA GUI
		listbox selecc "" pos:[9,53] width:143 height:8
		pickbutton pick "Pick Objects" pos:[10,7] width:75 height:25
		button remove "Remove" pos:[11,168] width:64 height:22
		button clearbtn "Clear" pos:[94,168] width:56 height:22
		label lbl1 "Objects to be replaced:" pos:[11,38] width:139 height:16
		button add_btn "Add" pos:[101,7] width:49 height:25
		
		on pick picked obj do --CUANDO PICKAMOS OBJETO VARIABLE OBJ PARA LO PICKADO
		( 
			arraystring = obj.name as string --CONVERTIMOS EL OBJETO SELECCIONADO EN NOMBRE Y VA A ARRAYSTRING
			appendIfUnique itemArray arraystring --AGREGA EL OBJETO SI NO ESTÁ
			selecc.items = itemArray --ACTUALIZA LISTBOX
			global coincidencia = finditem itemArray reemplazo1 --BUSCA QUE EL REEMPLAZO NO COINCIDA CON UN OBJETO
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
			
			listaSeleccionada = selectByName title: "Select Objects to Be Replaced" buttonText: "Add" filter:filtro  showHidden:False single:False
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
				global coincidencia = finditem itemArray reemplazo1 --BUSCA QUE EL REEMPLAZO NO COINCIDA CON UN OBJETO
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
	
	rollout reemplazorollout "Replacement" width:161 height:165
	(
		GroupBox grp2 "Replacement" pos:[6,7] width:147 height:39
		pickbutton pickreplacement "Pick replacement" pos:[43,58] width:90 height:28
		label lbl_replacement "<no objects>" pos:[16,24] width:121 height:19

		on pickreplacement picked terr do --CUANDO PICKAMOS UN REEMPLAZO VARIABLE TERR PARA LO PICKADO
		(	
			global reemplazo1 = terr.name --CONVERTIMOS EL OBJETO SELECCIONADO EN NOMBRE Y VA A ARRAYSTRING
			lbl_replacement.caption = reemplazo1 --CAMBIAMOS LA IMPRESIÓN EN EL MENU
			reemplazo = getnodebyname reemplazo1
			global coincidencia = finditem itemArray reemplazo1 --BUSCA QUE EL REEMPLAZO NO COINCIDA CON UN OBJETO
		)
	)
	
	rollout final "Execute" width:162 height:128
	(
		GroupBox grp1 "Messages" pos:[6,8] width:147 height:50
		label lbl_message "" pos:[11,23] width:139 height:24
		button start "Start Replacing" pos:[70,63] width:82 height:28 toolTip:""
			
		on final open do global natureReplacement = "open" --VARIABLE PARA NO ABRIR 2 VECES LA VENTANA
		on final close do global natureReplacement = undefined
			
		on chkdeg changed deg do (
			if deg == true then
			(
				global deg = true
			) else (
				global deg = false
			)
		)
		on start pressed do --CUANDO APRETAMOS EL BOTÓN START
		(
			if itemArray.count != 0 then --SI HAY OBJETOS SELECCIONADOS
			(
				if reemplazo1 != "" then--SI HAY UN REEMPLAZO SELECCIONADO
				(
					if coincidencia == 0 then --SI NO HAY COINCIDENCIA
					(
						lbl_message.caption = "" --SIN ERRORES
						estructura.seleccionar objeto --ELIGE UN OBJETO PARA REEMPLAZAR Y LO REEMPLAZA
						objetos.selecc.items = itemArray --ACTUALIZA LISTBOX Y LO BORRA
						--variations.spnZrot.value = Zrot --ACTUALIZA TODAS LAS VARIABLES DE LOS SPINNERS DE MODIFICAR
						--variations.spnXscal.value = Xscal
						--variations.spnYscal.value = Yscal
						--variations.spnZscal.value = Zscal
											
					) else (
						lbl_message.caption = "The replacement is the same as one of the objects."
					)
				) else (
					lbl_message.caption = "Please, select a replacement."
				)
			) else (
				lbl_message.caption = "Please, select an object."
			)
		)
	)
	
	rollout variations "Variations" width:162 height:150
	(
		spinner spnZrot "" pos:[70,9] width:58 height:16 range:[0,360,10] type:#float
		spinner spnXscal "" pos:[80,46] width:58 height:16 range:[0,1000,10] type:#float
		spinner spnYscal "" pos:[80,65] width:58 height:16 range:[0,1000,10] type:#float
		spinner spnZscal "" pos:[80,84] width:58 height:16 range:[0,1000,10] type:#float
	
		label lbl1 "Z Rotation:" pos:[14,10] width:55 height:16
		label lbl5 "deg" pos:[130,10] width:26 height:16
		label lbl6 " X:" pos:[66,47] width:16 height:16
		label lbl8 " Y:" pos:[65,66] width:16 height:16
		label lbl9 "%" pos:[140,66] width:11 height:16
		label lbl10 " Z:" pos:[65,85] width:16 height:16
		label lbl11 "%" pos:[140,85] width:11 height:16
		label lbl23 "%" pos:[140,47] width:11 height:16
		GroupBox grp1 "Scaling" pos:[6,33] width:147 height:80
	
		on variations open do --CUANDO SE ABRE EL ROLLOUT DEFINIMOS LOS VALORES DE LOS SPINNERS
		(
			spnZrot.value = Zrot
			spnXscal.value = Xscal
			spnYscal.value = Yscal
			spnZscal.value = Zscal
		)
		
		on spnZrot changed leo do Zrot = spnZrot.value
		on spnXscal changed leo do Xscal = spnXscal.value
		on spnYscal changed leo do Yscal = spnYscal.value
		on spnZscal changed leo do Zscal = spnZscal.value
	)
	
	rollout modificadores "Modifiers" width:162 height:354
	(
		checkbox chkNoise "On" pos:[12,17] width:41 height:18
		spinner spnnoise_amount "" pos:[80,34] width:58 height:16 type:#float
		spinner spnnoise_scale "" pos:[80,54] width:58 height:16 type:#float
		
		checkbox chkBend "On" pos:[12,105] width:41 height:18
		spinner spnbend_angle "" pos:[80,122] width:58 height:16 type:#float
		spinner spnbend_direction "" pos:[80,142] width:58 height:16 type:#float
		
		checkbox chkStretch "On" pos:[12,211] width:41 height:18
		spinner spnstretch_stretch "" pos:[80,228] width:58 height:16 range:[-1,1,0.1] type:#float 
 
		spinner spnstretch_amplify "" pos:[80,248] width:58 height:16 type:#float
		
		checkbox chkMeshsmooth "On" pos:[12,296] width:41 height:18
		spinner spnIterations "" pos:[77,317] width:58 height:16 range:[0,4,1] type:#integer
		
		GroupBox grp11 "MeshSmooth" pos:[6,281] width:147 height:69
		GroupBox grp4 "Noise" pos:[6,3] width:147 height:79
		GroupBox grp2 "Bend" pos:[6,89] width:147 height:99
		GroupBox grp3 "Stretch" pos:[6,195] width:147 height:79
		label lbl1 "Amount:" pos:[39,34] width:39 height:16
		label lbl3 "Angle:" pos:[49,122] width:32 height:16
		label lbl4 "Direction:" pos:[34,143] width:47 height:16
		label lbl9 "%" pos:[140,55] width:11 height:16
		label lbl12 "Scale:" pos:[51,55] width:31 height:16
		label lbl6 "Stretch:" pos:[41,228] width:38 height:16
		label lbl7 "Amplify:" pos:[41,249] width:40 height:16
		label lbl22 "Iterations:" pos:[27,318] width:51 height:16
		radioButtons bendaxis "" pos:[16,168] width:121 height:16 labels:#("X", "Y", "Z") columns:3
			
		on modificadores open do --CUANDO CARGA EL ROLLOUT
		(
			spnnoise_amount.value = Noise_amount --VALOR DEL SPINNER AMOUNT A VARIABLE
			spnnoise_amount.enabled = false --DESACTIVA EL SPINNER
			spnnoise_scale.value = Noise_escala --VALOR DEL SPINNER SCALE A VARIABLE
			spnnoise_scale.enabled = false --DESACTIVA EL SPINNER
			
			spnbend_angle.value = Bend_angle --VALOR DEL SPINNER ANGLE A VARIABLE
			spnbend_angle.enabled = false--DESACTIVA EL SPINNER
			spnbend_direction.value = Bend_direction --VALOR DEL SPINNER DIRECTION A VARIABLE
			spnbend_direction.enabled = false--DESACTIVA EL SPINNER
			
			spnstretch_stretch.value = Stretch_stretch --VALOR DEL SPINNER STRETCH A VARIABLE
			spnstretch_stretch.enabled = false--DESACTIVA EL SPINNER
			spnstretch_amplify.value = Stretch_amplify --VALOR DEL SPINNER AMPLIFY A VARIABLE
			spnstretch_amplify.enabled = false--DESACTIVA EL SPINNER
			
			spnIterations.enabled = false--DESACTIVA EL SPINNER
			bendaxis.enabled = false
			
		)
		on chkNoise changed chkNoise_test do --CUANDO CAMBIAMOS EL CHECK DE NOISE
		(
			if chkNoise_test == true then ( --SI LO ACTIVAMOS
				spnnoise_amount.enabled = true --ACTIVA SPINNERS
				spnnoise_scale.enabled = true
				global chkNoise_test = true --INFORMA QUE HAY QUE USAR EL NOISE
			) else ( --SI LO DESACTIVAMOS
				spnnoise_amount.enabled = false ----DESACTIVA SPINNERS
				spnnoise_scale.enabled = false
				global chkNoise_test = false--INFORMA QUE HAY QUE NO DEBEMOS USAR EL NOISE
			)
		)
		on spnnoise_amount changed vari do
			Noise_amount = spnnoise_amount.value
		on spnnoise_scale changed vari do
			Noise_escala = spnnoise_scale.value
		on bendaxis changed vari do 
			Bend_axis = bendaxis.state-1
		on chkBend changed chkBend_test do
		(
			if chkBend_test == true then ( --SI LO ACTIVAMOS
				spnbend_angle.enabled = true --ACTIVA SPINNERS
				spnbend_direction.enabled = true
				bendaxis.enabled = true
				global chkBend_test = true --INFORMA QUE HAY QUE USAR EL BEND
			) else ( --SI LO DESACTIVAMOS
				spnbend_angle.enabled = false ----DESACTIVA SPINNERS
				spnbend_direction.enabled = false
				bendaxis.enabled = false
				global chkBend_test = false --INFORMA QUE HAY QUE NO DEBEMOS USAR EL BEND
			)
		)
		on spnbend_angle changed varib do
			Bend_angle = spnbend_angle.value
		on spnbend_direction changed varib do
			Bend_direction = spnbend_direction.value
		on chkStretch changed chkStretch_test do
		(
			if chkStretch_test == true then ( --SI LO ACTIVAMOS
				spnstretch_stretch.enabled = true --ACTIVA SPINNERS
				spnstretch_amplify.enabled = true
				global chkStretch_test = true --INFORMA QUE HAY QUE USAR EL STRETCH
			) else (
				spnstretch_stretch.enabled = false----DESACTIVA SPINNERS
				spnstretch_amplify.enabled = false
				global chkStretch_test = false --INFORMA QUE HAY QUE NO DEBEMOS USAR EL STRETCH
			)
		)
		on spnstretch_stretch changed varic do
			Stretch_stretch = spnstretch_stretch.value
		on spnstretch_amplify changed varic do
			Stretch_amplify = spnstretch_amplify.value
		on chkMeshsmooth changed chkMeshsmooth_test do
		(
			if chkMeshsmooth_test == true then ( --SI LO ACTIVAMOS
				spnIterations.enabled = true --ACTIVA SPINNER
				global chkMeshsmooth_test = true --INFORMA QUE HAY QUE USAR EL STRETCH
			) else (
				spnIterations.enabled = false----DESACTIVA SPINNERS
				global chkMeshsmooth_test = false --INFORMA QUE HAY QUE NO DEBEMOS USAR EL STRETCH
			)
		)
		on spnIterations changed varic do
			Iterations = spnIterations.valueIterations = spnIterations.value
	)
	if natureReplacement != "open" then (
		Window = newRolloutFloater "Nature Replacement" 170 620 850 175 
		addRollout Objetos Window
		addRollout reemplazorollout Window
		addRollout final Window
		addRollout variations Window
		addRollout modificadores Window
	)
)