// module WebRTC.RTC

exports.newRTCPeerConnection_ = function(ice) {
    return function() {
        return new RTCPeerConnection(ice);
    };
};

exports.addStream = function(stream) {
    return function(pc) {
        return function() {
            pc.addStream(stream);
        };
    };
};

exports.onicecandidate = function(f) {
    return function(pc) {
        return function() {
            pc.onicecandidate = function(event) {
                f(event)();
            };
        };
    };
};

exports.onaddstream = function(f) {
    return function(pc) {
        return function() {
            pc.onaddstream = function(event) {
                f(event)();
            };
        };
    };
};

exports._createOffer = function(success) {
    return function(error) {
        return function(options) {
          return function(pc) {
              return function() {
                  pc.createOffer(options).then(
                      function(desc) {
                          success(desc)();
                      },
                      function(e) {
                          error(e)();
                      }
                  );
              };
          };
        };
    };
};

exports._createAnswer = function(success) {
    return function(error) {
        return function(pc) {
            return function() {
                pc.createAnswer().then(
                    function(desc) {
                        success(desc)();
                    },
                    function(e) {
                        error(e)();
                    }
                );
            };
        };
    };
};

exports._setLocalDescription = function(success) {
    return function(error) {
        return function(desc) {
            return function(pc) {
                return function() {
                    pc.setLocalDescription(
                        desc,
                        success,
                        function(e) {
                            error(e)();
                        }
                    );
                };
            };
        };
    };
};

exports._setRemoteDescription = function(success) {
    return function(error) {
        return function(desc) {
            return function(pc) {
                return function() {
                    pc.setRemoteDescription(
                        desc,
                        success,
                        function(e) {
                            error(e)();
                        }
                    );
                };
            };
        };
    };
};

exports._iceEventCandidate = function(nothing) {
    return function(just) {
        return function(e) {
            return e.candidate ? just(e.candidate) : nothing;
        };
    };
};

exports.addIceCandidate = function(c) {
    return function(pc) {
        return function() {
            pc.addIceCandidate(new RTCIceCandidate(c));
        };
    };
};

exports.newRTCSessionDescription = function(s) {
    return new RTCSessionDescription(s);
};

exports.createDataChannel = function(s) {
    return function(pc) {
        return function(success, error) {
            var dc = pc.createDataChannel(s);
            dc.onclose = function() {
                console.log("Data Channel '" + s + "' onclose");
            }
            dc.onerror = function(e) {
                console.log("Data Channel '" + s + "' onerror", e);
                error(e)();
            }
            dc.onopen = function() {
                console.log("Data Channel '" + s + "' onopen");
                success(dc);
            }
        };
    };
};

exports.send = function(s) {
    return function(dc) {
        return function() {
            if (dc.readyState != "open") return;
            dc.send(s);
        };
    };
};

// https://developer.mozilla.org/en-US/docs/Web/API/RTCPeerConnection/ondatachannel
exports.ondataChannel = function(c) {
  return function(success, err) {
      c.ondatachannel = function(e) {
        success(e.channel)();
      };
  }
}

exports.onmessageChannel = function(f) {
    return function(dc) {
        return function() {
            dc.onmessage = function(m) {
                console.log("onmessage", m);
                f(m)();
            };
        };
    };
};
