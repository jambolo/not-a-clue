`
import React from 'react';
import { createRoot } from 'react-dom/client';
import App from './App';
`

it 'renders without crashing', =>
  div = document.createElement 'div'
  root = createRoot div
  root.render <App />
  root.unmount()
  return
