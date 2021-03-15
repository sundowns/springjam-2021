extends Control

onready var bg: ColorRect = $ColorRect

func show():
	bg.color.a = 140.0/255.0

func hide():
	bg.color.a = 0.0
