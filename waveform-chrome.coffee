
@Waveform = ({file, canvas, onStatus,onReady}) ->
  canvas = $(canvas)
  status = $(status)

  sections = canvas.attr('width')

  self =
    view: WaveformView canvas

  req = new XMLHttpRequest()
  req.open 'GET', file, true
  req.responseType = 'arraybuffer'

  req.onprogress = (e) -> onStatus?(e.loaded/e.total)

  req.onload = -> loadBuffer req.response

  req.send()
  
  loadBuffer = (arr) ->
    audio = new webkitAudioContext()
    buf = audio.createBuffer(arr,true)
    
    ProcessAudio.extract(
      buf.getChannelData(0)
      sections, self.view.drawBar
    )
    
    self.playback = PlayBuffer audio, buf
    self.view.onCursor = self.playback.playAt
    
    setInterval(
      -> self.view.moveCursor self.playback.getTime()/buf.duration
      100
    )

    onReady?()

  self


@WaveformView = (canvas) ->
  {width,height} = canvas[0]
  ctx = canvas[0].getContext('2d')
  canvas[0].style.setProperty("background-color", "rgb(243, 205, 138)");

  cursor= $ """
    <div style="
      position: relative;
      height: #{height}px;
      width: 2px;
      background-color: #800;">
    """

  overlay = $ """
    <div style="
      position: relative;
      top: -#{height}px;
      height: 0px;">
    """

  overlay.append cursor
  canvas.after overlay

  canvas.click (e) ->
    mx = e.pageX-@offsetLeft
    cursor.css 'left', mx
    self.onCursor? mx/width

  self =
    drawBar: (i,val) ->
      h = val*50*height

      gradient = ctx.createLinearGradient(0,height/2-h/2,0,height/2+h/2)
      gradient.addColorStop( 0, "rgba(195, 127, 63, 0)")
      gradient.addColorStop(0.4, "rgba(195, 127, 63, 1)")
      gradient.addColorStop(0.6, "rgba(195, 127, 63, 1)")
      gradient.addColorStop(  1, "rgba(195, 127, 63, 0)")
      ctx.fillStyle = gradient

      ctx.fillRect(i,height/2-h/2,1,h)
    moveCursor: (pos) ->
      cursor.css 'left', pos*width


@PlayBuffer = (audio,buffer) ->
  node = null

  timeStart = null
  timeBasis = null
  paused = null

  start = (t) ->
    timeStart = Date.now()
    timeBasis = t
    
    node = audio.createBufferSource()
    node.buffer = buffer
    node.connect audio.destination
    if t==0
      node.noteOn 0
    else
      node.noteGrainOn 0, t, buffer.duration-t
  
  start(0)
  
  self =
    play: ->
      start(paused or 0)
      paused = null
    playAt: (t) ->
      node.noteOff 0
      start(t*buffer.duration)
      paused = null
    getTime: ->
      paused or
      Math.min(
        (Date.now()-timeStart)/1000 + timeBasis
        buffer.duration
      )
    pause: ->
      node.noteOff 0
      paused = self.getTime()
    isPaused: ->
      paused isnt null


@ProcessAudio =
  extract: (buffer, sections, out, done) ->
    len = Math.floor buffer.length/sections
    i = 0

    f = ->
      end = i+10
      while i<end
        pos = i*len
        out i, ProcessAudio.measure(pos,pos+len, buffer)
        i++
        if i >= sections
          clearInterval int
          done?()
          break

    int = setInterval f, 1

  measure: (a,b, data) ->
    sum = 0.0
    for i in [a..b-1]
      s = data[i]
      sum += s*s
    Math.sqrt sum/data.length

