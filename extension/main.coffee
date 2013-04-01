if ! localStorage.firstRun
  chrome.tabs.create({
     url: 'https://www.gmail.com'
  })
  localStorage.firstRun = true