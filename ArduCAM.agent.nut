class Camera {
    
    jpeg_buffer = null;
    jpeg_startat = 0;
    image = null;
    _cb = null;
    
    constructor(cb) {
        _cb = cb;
    }
    
    function init() {
        device.on("jpeg_start", function(size) {
            jpeg_buffer = blob(size);
            jpeg_startat = time();
        }.bindenv(this));
        
        device.on("jpeg_chunk", function(v) {
            // check we've not got some barf from a previous boot
            if (this.jpeg_buffer == null) return;
        
            local offset = v[0];
            local b = v[1];
            for(local i = offset; i < (offset+b.len()); i++) {
                if(i < jpeg_buffer.len()) {
                    jpeg_buffer[i] = b[i-offset];
                }
            }
        }.bindenv(this));
    
        device.on("jpeg_end", function(v) {
            // check we've not got some barf from a previous boot
            if (jpeg_buffer == null) return;
        
            // copy last JPEG to web server blob
            image = jpeg_buffer
            
            server.log("done");
            
            if(_cb) {
                _cb(image);
            }
        }.bindenv(this));
    }
    
    function getAgentMemoryLeft() {
        return imp.getmemoryfree();
    }
    
    function setCallback(cb) {
        _cb = cb;
    }
}