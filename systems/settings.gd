extends Node

enum INPUT_DEVICE {MOUSE, CONTROLER}
var current_input_device : INPUT_DEVICE = INPUT_DEVICE.CONTROLER

var mouse_sensitivity := 0.002
var horizontal_acceleration_controler := 4.0
var vertical_acceleration_controler := 2.0
