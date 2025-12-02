`
import React from 'react'
import { createRoot } from 'react-dom/client'
import './index.css'
import App from './App'
import registerServiceWorker from './registerServiceWorker'
`

rootElement = document.getElementById 'root'
root = createRoot rootElement
root.render <App />
do registerServiceWorker
