// module WebRTC.MediaStream

exports._getUserMedia = function(success) {
    return function(error) {
        return function(constraints) {
            return function() {
                // https://webrtc.org/web-apis/interop/
                // https://developer.mozilla.org/en-US/docs/Web/API/MediaDevices/getUserMedia
                var getUserMedia = navigator.mediaDevices.getUserMedia;

                return getUserMedia.call(
                    navigator,
                    constraints,
                    function(r) { success(r)(); },
                    function(e) { error(e)(); }
                );
            };
        };
    };
};

exports.createObjectURL = function(blob) {
    return function() {
        return URL.createObjectURL(blob);
    };
};
