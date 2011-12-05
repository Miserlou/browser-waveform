# Browser-Waveform
## From [Gun.io](http://gun.io)
### Client-side waveform rendering of an audio track in pure JavaScript.

Currently works in Chrome through the 'webkitAudioContext' object.

Firefox only has their own useless nonstandard sound API thing that makes Flash look good.

## Coffee to JavaScript
* npm install -g coffee-script
* coffee --compile chrome-waveform.coffee

## Notes
For local testing, remember to run Chrome locally with --allow-file-access-from-files.

* OSX: open /Applications/Google\ Chrome.app --args --allow-file-access-from-files

## Example
* See waveform.html

## Schema 

    Waveform :: ({file, canvas, onStatus, onReady}) -> {
      playback :: { moveCursor :: (Num) -> () }
      view :: {
        play     :: -> ()
        playAt   :: (Num) -> ()
        getTime  :: -> Num
        pause    :: -> ()
        isPaused :: -> Bool
      }
    }
