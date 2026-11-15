const { spawn } = require('child_process');

// el hijo lanza un NIETO en segundo plano y se muere enseguida:
// el nieto queda huérfano y lo adopta PID 1, que es quien tendrá que enterrarlo
setInterval(function () {
  spawn('/bin/bash', ['-c', '/bin/sleep 2 & exit 0']);
}, 300);
setInterval(function () {}, 1 << 30);
