//Provides: unix_mkdir
function unix_mkdir () {
}

//Provides: caml_channel_descriptor
function caml_channel_descriptor () {
}

//Provides: unix_dup
function unix_dup () {
}

//Provides: unix_dup2
function unix_dup2 () {
}

//Provides: unix_open
function unix_open () {
}

//Provides: unix_close
function unix_close () {
}
//Provides: unix_execv
function unix_execv () {
}

//Provides: unix_fork
function unix_fork () {
}

//Provides: unix_pipe
function unix_pipe () {
}

//Provides: unix_set_close_on_exec
function unix_set_close_on_exec () {
}

//Provides: unix_waitpid
function unix_waitpid () {
}

//Provides: unix_isatty
function unix_isatty () {
}

//Provides: js_print_stdout (const)
function js_print_stdout(s) {
  if (!window.stdout_buffer) {
    window.stdout_buffer = [];
  }
  window.stdout_buffer.push(s);
}
