# Created by Freeknight
# 2021/12/01
# 说明：
#-------------------------------------------------
tool
extends EditorPlugin
#-------------------------------------------------
const Toolbar = preload("UI/Toolbar.tscn")
const OverlayTextEdit = preload("UI/OverlayTextEdit.tscn")
#-------------------------------------------------
var toolbar
var overlay_text_edit
#-------------------------------------------------
var editor_inspector = get_editor_interface().get_inspector()
var editor_selection = get_editor_interface().get_selection()
#-------------------------------------------------
func _enter_tree():
	toolbar = Toolbar.instance()
	toolbar.undo_redo = get_undo_redo()
	toolbar.connect("property_edited", self, "_on_Toolbar_property_edited")
	overlay_text_edit = OverlayTextEdit.instance()
	overlay_text_edit.undo_redo = get_undo_redo()
	overlay_text_edit.connect("property_edited", self, "_on_OverlayTextEdit_property_edited")

	editor_inspector.connect("property_selected", self, "_on_property_selected")
	editor_selection.connect("selection_changed", self, "_on_selection_changed")

	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, toolbar)
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_BOTTOM, overlay_text_edit)
#-------------------------------------------------
func _exit_tree():
	if toolbar:
		toolbar.queue_free()
	if overlay_text_edit:
		overlay_text_edit.queue_free()
#-------------------------------------------------
func handles(object):
	if object is Control:
		make_visible(true)
		return true
	make_visible(false)
	return false
#-------------------------------------------------
func forward_canvas_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.doubleclick: # Always false when selected multiple nodes
				if toolbar.focused_objects:
					overlay_text_edit.popup()
				return true
	return false
#-------------------------------------------------
func make_visible(visible):
	if toolbar:
		toolbar.visible = visible
	#overlay_text_edit only visible on double click
#-------------------------------------------------
func _on_property_selected(property):
	toolbar.focused_property = property
	toolbar.focused_inspector = editor_inspector.get_focus_owner()
#-------------------------------------------------
func _on_selection_changed():
	var selections = editor_selection.get_selected_nodes()
	var is_visible = false
	var focused_objects = []
	if selections.size() == 1:
		var selection = selections[0]
		if selection is Control:
			focused_objects = [selection]
			is_visible = true
	elif selections.size() > 1:
		var has_non_control = false
		for selection in selections:
			if not (selection is Control):
				has_non_control = true
				break
		if not has_non_control:
			is_visible = true
			focused_objects = selections
	toolbar.visible = is_visible
	toolbar.focused_objects = focused_objects
	overlay_text_edit.focused_objects = focused_objects
#-------------------------------------------------
func _on_Toolbar_property_edited(property):
	editor_inspector.refresh()
#-------------------------------------------------
func _on_OverlayTextEdit_property_edited(property):
	editor_inspector.refresh()
#-------------------------------------------------
