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

//Provides: js_print_stdout (const)
function js_print_stdout(s) {
  if (!window.stdout_buffer) {
    window.stdout_buffer = [];
  }
  window.stdout_buffer.push(s);
}

//Provides: js_print_stderr (const)
function js_print_stderr(s) {
  if (!window.stderr_buffer) {
    window.stderr_buffer = [];
  }
  window.stderr_buffer.push(s);
}
