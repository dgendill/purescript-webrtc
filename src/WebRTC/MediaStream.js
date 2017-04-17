// module WebRTC.MediaStream

exports._getUserMedia = function(success) {
    return function(error) {
        return function(constraints) {
            return function() {
                // https://webrtc.org/web-apis/interop/
                // https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia
                var getUserMedia = navigator.mediaDevices.getUserMedia;

                return getUserMedia(constraints).then(function(stream) {
                  success(stream)();
                }, function(e) {
                  error(e)();
                });
              
            };
        };
    };
};

exports.createObjectURL = function(blob) {
    return function() {
        return URL.createObjectURL(blob);
    };
};
