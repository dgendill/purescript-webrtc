// module WebRTC.RTC

exports.newRTCPeerConnection_ = function(ice) {
    return function() {
        return new RTCPeerConnection(ice);
    };
};

exports.onicecandidate = function(pc) {
    return function(f) {
        return function(success, error) {
            pc.onicecandidate = function(event) {
                f(event)(function() {}, function() {});

                // We have the "end-of-candidate" value,
                // so we should be done now.
                if (event.candidate === null) {
                  success(pc.localDescription);
                }
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
                        // Older version of FF reuire an actual
                        // RTCSessionDescription object.
                        new RTCSessionDescription(desc),
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
            if (!e.candidate) return nothing;

            if (e.candidate.candidate == "" || e.candidate.candidate == null) {
                e.candidate.candidate = nothing;
            }

            return just(e.candidate);
        };
    };
};

exports.localDescription_ = function(just) {
  return function(nothing) {
    return function(c) {
      var ld = c.localDescription;
      return c ? just(c) : nothing;
    }
  }
}

exports.addIceCandidate = function(c) {
    return function(pc) {
        return function() {
            console.log('adding ice candidate', c);
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

exports.oncloseChannel = function(c) {
  return function(aff) {
    return function(success, err) {
      console.log('adding onclose event.');
      c.onclose = function(event) {
        console.log('close!');
        aff(function() {
          console.log('calling success function');
          success();
        }, function() {
          err();
        })
      }
    }
  }
}

exports.closeConnection = function(pc) {
  return function(success, err) {
    pc.close();
    success()
  }
}

exports.onmessageChannelOnce = function(dc) {
    return function(success, error) {
        var ran = false;
        dc.onmessage = function(e) {
            console.log("onmessage");
            if (!ran) {
              ran = true;
              success(e.data);
            }
        };
    };
};
