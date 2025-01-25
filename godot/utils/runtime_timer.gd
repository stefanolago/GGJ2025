extends Node

func _init_timer(wait_time: float, autostart: bool, one_shot: bool, callback: Callable) -> Timer:
    var timer: Timer = Timer.new()
    timer.wait_time = wait_time
    timer.autostart = autostart
    timer.one_shot = one_shot 
    add_child(timer)
    timer.timeout.connect(callback)
    return timer
