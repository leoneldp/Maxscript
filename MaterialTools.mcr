macroScript MaterialVisibilities
category:"Render Lab Tools"
tooltip: "Material Visibility Manager"
buttonText:"MatVisibility"
( 
	global BMask1 = bitmap 18 14 color: white
	global pathLab = getINISetting  ((GetDir #maxroot) +"HumanLab.ini") "Directories" "installationPath"
	global fileIcons=pathlab+ "Icons\\"
	global generateRolloutMat
	global actualizarLista
	global abrirVentRender
	global TexturesManager
	MatPath = undefined
	MatSize = [1000,1000]
	local render_map_settings,DisableProcessWindowsGhosting,renderMaps,Window,tobeRendereredmaterial
	global GhostingDesactivado
	--tobeRendereredmaterial = sceneMaterials[1]
	
	rollout estadisticas "Statistics" width:184 height:226
	(
		label lbl1 "Material count:" pos:[13,10] width:82 height:16
		label lbl2 "" pos:[97,10] width:34 height:16
		
		on estadisticas open do (
			lbl2.caption = sceneMaterials.count as string
		)
	)

	rollout render_map_settings ("Render Map: "+tobeRendereredmaterial.name as string) width:184 height:700
	(
		label lbl2 "Map Render Size:" width:280 heigth: 16 pos: [13,15]
		spinner spnSize "" range: [0,30000,1000] type:#integer width: 55 pos:[105,15]
		label lbl3 "pixels" width:280 heigth: 16 pos: [165,15]
		edittext editCharMatPath text:"Choose the folder to place bitmaps..." pos:[80,47] fieldWidth:200 labelOnTop:false readOnly:true enabled: false
		button btnBrowse "Browse..." width:66 height:20 pos:[13,45]
		button btnRender "Render Map" width:66 height:20 align: #right offset: [0,15]
		label lbl_message "Please select the correct settings for the render." align: #center width:240 height:23 offset: [0,25]
		GroupBox grp1 "Messages" pos:[6,110] width:278 height:53
		
		on render_map_settings open do btnRender.enabled = false
			
		on spnSize changed thestate do MatSize = [thestate,thestate]
			
		on btnBrowse pressed do (
			MatPath = getSavePath caption:"Pick the installation folder" initialDir: "c:\\"
			if MatPath != undefined then ( --SI ELEGIMOS UNA CARPETA
				editCharMatPath.text = (pathConfig.normalizePath MatPath) --ASIGNAMOS RUTA AL "LABEL"
				btnRender.enabled = true
			)
		)
		
		on btnRender pressed do (
			if MatPath != undefined then (
				if GhostingDesactivado != true then (
					DisableWindowsGhosting = DisableProcessWindowsGhosting()
					DisableWindowsGhosting.DisableProcessWindowsGhosting()
					GhostingDesactivado = true
				)
				renderMaps()
			)
		)
	)
	
	function renderMaps =(
	--SI ES ARCH AND DESIGN
			if (ClassOf tobeRendereredmaterial) ==Arch___Design__mi then (
				render_map_settings.lbl_message.caption = "Rendering Arch and Design Material..."
				if tobeRendereredmaterial.mapM0 != undefined then (--DIFFUSE
					rm = renderMap tobeRendereredmaterial.mapM0 filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Dif.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.mapM0 = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Dif.png")
				)
				if tobeRendereredmaterial.mapM2 != undefined  then (--REFLECTION COLOR MAP 
					rm = renderMap tobeRendereredmaterial.mapM2 filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Refl.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.mapM2 = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Refl.png")
				)
				if tobeRendereredmaterial.mapM3 != undefined  then (--GLOSSINESS MAP 
					rm = renderMap tobeRendereredmaterial.mapM3 filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Glos.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.mapM3 = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Glos.png")
				)
				if tobeRendereredmaterial.mapM4 != undefined  then (--REFRACTION COLOR 
					rm = renderMap tobeRendereredmaterial.mapM4 filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Refr.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.mapM4 = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Refr.png")
				)
				if tobeRendereredmaterial.bump_map != undefined  then (--BUMP
					rm = renderMap tobeRendereredmaterial.bump_map filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Bump.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.bump_map = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Bump.png")
				)
				if tobeRendereredmaterial.cutout_map != undefined  then (--CUTTOUT
					rm = renderMap tobeRendereredmaterial.cutout_map filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Cut.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.cutout_map = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Cut.png")
				)
			-->>>///CERRAR VENTANA
				fn cargar =(
					closeRolloutFloater Window
				)
				theTimer = dotNetObject "System.Windows.Forms.Timer"	
				theTimer.interval = 1000
				dotnet.addEventHandler theTimer "tick" cargar
				theTimer.start() --INICIAMOS TIMER

				render_map_settings.lbl_message.caption = "The render has finished."
	--SI ES UN MATERIAL STANDARD
			) else (
			if (ClassOf tobeRendereredmaterial) == standardMaterial then ( 
				render_map_settings.lbl_message.caption = "Rendering Standard Material..."
				if tobeRendereredmaterial.diffuseMap != undefined then (--DIFFUSE
					rm = renderMap tobeRendereredmaterial.diffuseMap filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Dif.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.diffuseMap = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Dif.png")
				)
				if tobeRendereredmaterial.specularMap != undefined then (--SPECULAR COLOR
					rm = renderMap tobeRendereredmaterial.specularMap filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Spec_Color.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.specularMap = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Spec_Color.png")
				)
				if tobeRendereredmaterial.glossinessMap != undefined then (--GLOSSINES
					rm = renderMap tobeRendereredmaterial.glossinessMap filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Gloss.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.glossinessMap = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Gloss.png")
				)
				if tobeRendereredmaterial.specularLevelMap != undefined then (--SPECULAR LEVEL
					rm = renderMap tobeRendereredmaterial.specularLevelMap filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Spec_Level.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.specularLevelMap = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Spec_Level.png")
				)
				if tobeRendereredmaterial.opacityMap != undefined then (--OPACITY
					rm = renderMap tobeRendereredmaterial.opacityMap filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Opac.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.opacityMap = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Opac.png")
				)
				if tobeRendereredmaterial.bumpMap != undefined then (--BUMP
					rm = renderMap tobeRendereredmaterial.bumpMap filename: (MatPath+"\\"+tobeRendereredmaterial.name+" Bump.png") size: MatSize display: true
					save rm;	close rm
					tobeRendereredmaterial.bumpMap = Bitmaptexture fileName:(MatPath+"\\"+tobeRendereredmaterial.name+" Bump.png")
				)
			-->>>///CERRAR VENTANA
				fn cargar =(
					closeRolloutFloater Window
				)
				theTimer = dotNetObject "System.Windows.Forms.Timer"	
				theTimer.interval = 1000
				dotnet.addEventHandler theTimer "tick" cargar
				theTimer.start() --INICIAMOS TIMER
				
				render_map_settings.lbl_message.caption = "The render has finished."
			)
		)
	)
	
--///////////////////////////////////////////////////////////////////////////////FUNCIÓN PARA DESACTIVAR EL ERROR CAUSADO POR EL GHOSTING
	fn DisableProcessWindowsGhosting = (
		if classof (dotnet.GetType "DisableWindowsGhosting")!=dotNetObject do	 (
			local source = StringStream ("
			using System.Runtime.InteropServices;

			public class DisableWindowsGhosting
			{
			[DllImport(\"user32.dll\")]
			public static extern bool DisableProcessWindowsGhosting();
			}")
			compilerParams = dotnetobject "System.CodeDom.Compiler.CompilerParameters"
			compilerParams.ReferencedAssemblies.Add("System.dll");
			compilerParams.GenerateInMemory = on
			csharpProvider = dotnetobject "Microsoft.CSharp.CSharpCodeProvider"
			compilerResults = csharpProvider.CompileAssemblyFromSource compilerParams #(source as String)
			flush source
			close source
			if (compilerResults.Errors.Count > 0 ) then	 (
				local errs = stringstream ""
				for i = 0 to (compilerResults.Errors.Count-1) do (
					local err = compilerResults.Errors.Item[i]
					format "Error:% Line:% Column:% %\n" err.ErrorNumber err.Line err.Column err.ErrorText to:errs
				)
				format "%\n" errs
				undefined
			) else (
				compilerResults.CompiledAssembly.CreateInstance "DisableWindowsGhosting"
			)
		)
	)
	
	function abrirVentRender texturaNumero= (
		tobeRendereredmaterial = scenematerials[texturaNumero as integer]
		Window = newRolloutFloater "Render Map Settings" 310 200 850 175 
		addRollout render_map_settings Window
	)
	
	function actualizarLista numero = (
		removeSubRollout gral.subroll TexturesManager
		TexturesManager = undefined
		generateRolloutMat 1 --EJECUTA FUNCIÓN PARA CREAR ROLLOUT DE MATERIALES
		AddSubRollout gral.subroll TexturesManager
		removeSubRollout gral.subroll estadisticas
		AddSubRollout gral.subroll estadisticas
	)
	
	function generateRolloutMat amount=(	
		global checkmaterials	= #()
		global mapsarray = #()
		rci = rolloutCreator "TexturesManager" "List of Materials in Scene"
		rci.begin()
		rci.addControl #button #btnRefresh "Refresh" paramStr: "height:20 width:60 align: #right"
		rci.addControl #label #title1 "Material name:" paramStr: "height:16 align: #left across:4" --AGREGAMOS CONTROLES TÍTULOS
		rci.addControl #label #title2 "Visible" paramStr: "height:16 align: #right offset: [100,0]"
		rci.addControl #label #title3 "Slot" paramStr: "height:16 align: #right offset: [47,0]"
		rci.addControl #label #title4 "Render" paramStr: "height:16 align: #right offset: [12,0]"
		
		if sceneMaterials.count>0 then ( --SI EXISTE ALGÚN MATERIAL EN LA ESCENA
			for i = 1 to sceneMaterials.count do (
				captionlbl = ("· "+ sceneMaterials[i].name)
				lblname = ("label"+i as string) as string
				rci.addControl #label lblname captionlbl paramStr:"width: 250 height:14 align:#left across:4 offset: [10,0]"  --LABEL NOMBRE
				chkname = ("checkbutton"+i as string) as name
				chkparametros = "width:18 height:14 align:#right offset: [94,0]  border: false tooltip:\"Click to show/hide material\" "
				if (superClassOf sceneMaterials[i]) ==material then	(
					append checkmaterials sceneMaterials[i].showInViewport
					chkparametros1 = "checked: "+ sceneMaterials[i].showInViewport as string + " "+ chkparametros
					slot = (findItem meditMaterials sceneMaterials[i]) as string
				) else (
					chkparametros1 = "checked: false enabled:false "+ chkparametros
					slot = ""
					append mapsarray i
				)
				rci.addControl #checkbutton  chkname "" paramStr: chkparametros1 --BOTÓN ACTIVA VISIBILIDAD
				rci.addHandler chkname #changed paramStr:"val" codeStr: ("showTextureMap sceneMaterials["+i as string+"] "+chkname+".state")
				lblmtlname = ("labelmtl"+i as string) as name
				
				if slot == "0" then slot = ""
				rci.addControl #label lblmtlname slot paramStr:"height:16 align:#right offset: [37,0]" --LABEL SLOT
				
				if (ClassOf sceneMaterials[i]) ==Arch___Design__mi or (ClassOf sceneMaterials[i]) == standardMaterial then (
					btnRenderParametros = "height:16 align:#right enabled: true"
				) else (
					btnRenderParametros = "height:16 align:#right enabled: false"
				)
				bntrendername = ("render"+i as string) as name
				rci.addControl #button bntrendername "" paramStr:btnRenderParametros --BOTÓN RENDER
				rci.addHandler bntrendername #pressed codeStr: ("abrirVentRender "+ i as string)--("print  sceneMaterials["+i as string+"].name")
			)
			falso = finditem checkmaterials false --BUSCA SI EL MATERIAL ESTÁ ACTIVADO EN LA VISTA PARA LEER ESTADO CHK BUTTON
			if falso == 0 then chktodosEstado = true else chktodosEstado = false
			chktodosparametros = "checked: "+ chktodosEstado as string+ " width:20 height:16 align: #right offset: [79,0]"
			rci.addControl #label #lbltodos "Show All:" paramStr: "height:16 align: #right across:3 offset: [148,2]" --AGREGAMOS CONTROLES FINAL
			rci.addControl #checkbox #chktodos "" paramStr: chktodosparametros
			rci.addHandler #chktodos #changed paramStr:"valtodos" codeStr: "for c in TexturesManager.controls do if (isKindOf c CheckButtonControl) == true then c.checked = valtodos;for i = 1 to sceneMaterials.count do (if (findItem mapsarray i)>0 do continue;showTextureMap sceneMaterials[i] valtodos)"
			rci.addHandler #TexturesManager #open codeStr: "for c in TexturesManager.controls do if (isKindOf c CheckButtonControl) == true then c.images = #(fileIcons+@clothing_showtext_16i.png@,BMask1,3,2,1,3,3,true,false);for c in TexturesManager.controls do (if c.name == @btnRefresh@ do continue;if (isKindOf c ButtonControl) == true then c.images = #(@Render_16i.bmp@,BMask1,13,7,7,8,8,true,false))"
		)
		rci.addHandler #btnRefresh #pressed codeStr: "actualizarLista 1"
		rci.end()
	)
		rollout gral "Material Visibility Manager" width:224 height:700
		(
			subrollout subroll "test1" pos: [10, 10] width:370 height:630 border: false
			
			on gral open do (
				generateRolloutMat 1 --EJECUTA FUNCIÓN PARA CREAR ROLLOUT DE MATERIALES
				AddSubRollout gral.subroll TexturesManager
				AddSubRollout gral.subroll estadisticas
				global abierto = true
			)
			on gral close do (
				global abierto = false
			)
		)
	if abierto != true then createDialog gral pos: [800,100] width:390 height:650 style: #(#style_titlebar,#style_resizing, #style_sysmenu, #style_minimizebox) lockHeight: true lockWidth: true escapeEnable: true
)