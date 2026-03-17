#Requires AutoHotkey v2.0

; --- LIBRERIAS Y ARCHIVOS ---
#Include "lib\JSON.ahk"
#Include GuiConfig.ahk

SetKeyDelay -1

; --- RUTAS DE ARCHIVOS ---
global PrefabsPath := A_ScriptDir . "\data\prefabs.json"
global CredsPath   := A_ScriptDir . "\secrets\credentials.json"
global CommandsPath := A_ScriptDir . "\data\commands.json"
global DataMap     := Map()

; --- INICIO DEL SCRIPT ---

; Inicializacion de la GUI (se crea pero se mantiene oculta)
global UI := CrearInstanciaGui(FilterList)

CargarTodo()

; --- EL DISPATCHER (Cerebro de Comandos) ---
; Aquí es donde defines qué hace cada palabra clave del JSON
Dispatcher(accion) {
    switch accion, false { ; false = no distingue mayúsculas/minúsculas
        case "Reload":
            Reload()
        case "Exit":
            ExitApp()
        case "OpenData":
            Run(A_ScriptDir . "\data")
        default:
            MsgBox("Comando reconocido pero no tiene acción definida: " . accion)
    }
}

CargarTodo() {
    CargarCredenciales()
    CargarPrefabs()
	CargarComandos()
}

CargarComandos() {
    if !FileExist(CommandsPath)
        return
    try {
        contenido := FileRead(CommandsPath, "UTF-8")
        cmdsObj := JSON.Parse(contenido)
        Tipo := Type(cmdsObj)

        ; Capturamos el atajo y el nombre de la acción
        VincularComando(atajo, nombreAccion) {
            Hotstring(":X*:" . atajo, (*) => Dispatcher(nombreAccion))
        }

        if (Tipo = "Map") {
            for atajo, accion in cmdsObj
                VincularComando(atajo, accion)
        } else {
            for atajo, accion in cmdsObj.OwnProps()
                VincularComando(atajo, accion)
        }
    } catch Error as e {
        MsgBox("Error cargando comandos: " e.Message)
    }
}

CargarCredenciales() {
    if !FileExist(CredsPath)
        return
    try {
        contenido := FileRead(CredsPath, "UTF-8")
        creds := JSON.Parse(contenido)
        
        Tipo := Type(creds)
        
        ; Esta función interna "captura" el valor actual de comando
        CrearHotstring(atajo, cmd) {
            Hotstring(":X*:" . atajo, (*) => EjecutarEnvio(cmd))
        }

        if (Tipo = "Map") {
            for atajo, comando in creds
                CrearHotstring(atajo, comando)
        } else {
            for atajo, comando in creds.OwnProps()
                CrearHotstring(atajo, comando)
        }
    } catch Error as e {
        MsgBox("Error cargando credenciales: " e.Message)
    }
}

CargarPrefabs() {
    if !FileExist(PrefabsPath) {
        MsgBox("Error: No existe " . PrefabsPath)
        return
    }

    try {
        contenido := FileRead(PrefabsPath, "UTF-8")
        ; Limpiamos posibles espacios o caracteres invisibles al inicio/final
        contenido := Trim(contenido, " `t`n`r") 
        
        data := JSON.Parse(contenido)
        DataMap.Clear()

        ; --- LA PRUEBA DE FUEGO ---
        ; Esto nos dirá qué tipo de dato devolvió la librería
        TipoDato := Type(data)

        if (TipoDato = "Map") {
            for clave, valor in data
                DataMap[clave] := valor
        } 
        else if (IsObject(data)) {
            ; Si es un objeto genérico, intentamos recorrer sus propiedades
            for clave, valor in data.OwnProps()
                DataMap[clave] := valor
        }

        if (DataMap.Count = 0) {
            MsgBox("Leído como: " . TipoDato . "`nContenido: " . SubStr(contenido, 1, 100) . "...`n`nNo se encontraron llaves.")
        }
    } catch Error as e {
        MsgBox("Error crítico en JSON: " e.Message)
    }
}

; --- FUNCIÓN DE ENVÍO UNIFICADA ---
EjecutarEnvio(texto) {
    if InStr(texto, "{TAB}") {
        partes := StrSplit(texto, "{TAB}")
        SendText(partes[1])
        Send("{Tab}")
        if (partes.Length > 1)
            SendText(partes[2])
    } else {
        SendEvent("{Text}" . texto)
    }
}

; --- BOTÓN DE PÁNICO ---
^Esc::ExitApp 

; --- ATAJO PRINCIPAL ---
- & Tab:: {
    ; Validación rápida de datos
    if (!IsSet(DataMap) || DataMap.Count = 0) {
        MsgBox("Error: No hay datos cargados en el sistema.")
        return
    }

    ; Preparar la interfaz antes de mostrarla
    UI.Search.Value := ""      ; Limpiar búsqueda anterior
    UI.List.Delete()           ; Limpiar lista anterior
    
    ; Cargar todos los nombres inicialmente
    Nombres := []
    for Nombre, _ in DataMap
        Nombres.Push(Nombre)
    
    UI.List.Add(Nombres)
    if (Nombres.Length > 0)
        UI.List.Choose(1)

    ; Mostrar y dar foco inmediato al buscador
    UI.Gui.Show()
    UI.Search.Focus()
}

-:: Send("-")

; --- LÓGICA DE FILTRADO ---
FilterList(*) {
    TextoBusqueda := UI.Search.Value
    NuevosResultados := []
    
    for Nombre, Contenido in DataMap {
        if (TextoBusqueda = "" || InStr(Nombre, TextoBusqueda))
            NuevosResultados.Push(Nombre)
    }
    
    UI.List.Opt("-Redraw") ; Evita parpadeo visual
    UI.List.Delete()
    if (NuevosResultados.Length > 0) {
        UI.List.Add(NuevosResultados)
        UI.List.Choose(1)
    }
    UI.List.Opt("+Redraw")
}

#HotIf WinActive("ahk_id " . UI.Gui.Hwnd) ; Usamos el ID único de la ventana para mayor precisión

; --- NAVEGACIÓN HACIA ABAJO ---
$Down:: {
    ; Si estamos en el buscador, bajamos a la lista
    if (UI.Gui.FocusedCtrl == UI.Search) {
        UI.List.Focus()
        ; Si el primer ítem ya está seleccionado por el filtro, 
        ; enviamos una flecha abajo extra para ir al segundo.
        if (UI.List.Value == 1) {
            Send("{Down}")
        }
    } else {
        ; Si ya estamos en la lista, que la flecha abajo funcione normal
        Send("{Down}")
    }
}

; --- NAVEGACIÓN HACIA ARRIBA ---
$Up:: {
    ; Si estamos en la lista y ya llegamos al primer elemento, volvemos al buscador
    if (UI.Gui.FocusedCtrl == UI.List && UI.List.Value == 1) {
        UI.Search.Focus()
    } else {
        ; En cualquier otro caso (o si estamos en el buscador), flecha arriba normal
        Send("{Up}")
    }
}

; Al presionar Enter: Obtiene el texto, oculta la GUI y envía
Enter:: {
    ChosenName := UI.List.Text
    if (ChosenName != "" && DataMap.Has(ChosenName)) {
        TextoFinal := DataMap[ChosenName]
        
        UI.Gui.Hide() ; Usamos Hide en lugar de Destroy para mantener la "instancia única"
        Sleep(100)    ; Breve pausa para asegurar que el foco vuelva a WhatsApp/App destino
        
        EjecutarEnvio(TextoFinal)
    }
}

; Esc solo oculta la ventana, no la elimina de memoria
Esc:: UI.Gui.Hide()

#HotIf