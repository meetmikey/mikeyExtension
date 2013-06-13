if ! localStorage.firstRun
  chrome.tabs.create({
     url: 'https://www.gmail.com'
  })
  localStorage.firstRun = true

 copyTextToClipboard = (text) ->
  copyDiv = document.createElement('div')
  copyDiv.contentEditable = true
  document.body.appendChild copyDiv
  copyDiv.innerHTML = text
  copyDiv.unselectable = "off"
  copyDiv.focus()
  document.execCommand 'SelectAll'
  document.execCommand 'Copy', false, null
  document.body.removeChild copyDiv

chrome.runtime.onMessage.addListener (request, sender, sendResponse) ->
  if ( request.type == 'copyTextToClipboard' )
    copyTextToClipboard request.text
  sendResponse
    isSuccess: true
