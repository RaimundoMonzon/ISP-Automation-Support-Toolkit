#Requires AutoHotkey v2.0

; Esta función crea la ventana una sola vez y la deja oculta en memoria
CrearInstanciaGui(EventoFiltrado) {
    ; Configuración de la Ventana
    MyGui := Gui("+AlwaysOnTop -Caption +Border +LastFound", "XG_Launcher")
    MyGui.BackColor := "0D1B1E" ; Verde oscuro profundo
    WinSetTransparent(225, MyGui)

    ; Título Estilizado
    MyGui.SetFont("s10 Bold c2ECC71", "Segoe UI")
    MyGui.Add("Text", "w350 Center", "🔍 BUSCADOR SOPORTE XG")

    ; Campo de Entrada (Edit)
    MyGui.SetFont("s12 cE0E0E0", "Consolas")
    ; -E0x200 quita el borde interno clásico para un look plano
    SearchEdit := MyGui.Add("Edit", "w350 vSearchText +Center -E0x200")
    
    ; Lista de Resultados (ListBox)
    MyGui.SetFont("s10 cE0E0E0", "Segoe UI")
    ResultList := MyGui.Add("ListBox", "w350 r12 vResultList Background0D1B1E")

    ; Eventos Básicos
    SearchEdit.OnEvent("Change", EventoFiltrado)
    MyGui.OnEvent("Escape", (*) => MyGui.Hide()) ; Esc para cerrar rápido

    return {Gui: MyGui, Search: SearchEdit, List: ResultList}
}