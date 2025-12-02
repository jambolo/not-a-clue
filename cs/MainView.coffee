`
import Button from '@mui/material/Button';
import CurrentState from './CurrentState'
import Divider from '@mui/material/Divider'
import React from 'react';
import TopBar from './TopBar'
`

MainView = (props) ->
  { configurationId, solver, app } = props
  { showHandDialog, showSuggestDialog, showShowDialog, showAccuseDialog, showCommlinkDialog } = app

  <div className="MainView">
    <TopBar onMenu={props.onMenu} />
    {
      if solver?
        <div>
          <Button variant="contained" color="primary" onClick={showHandDialog}> Hand </Button>
          <Button variant="contained" color="primary" onClick={showSuggestDialog}> Suggest </Button>
          <Button variant="contained" color="primary" onClick={showShowDialog}> Show </Button>
          <Button variant="contained" color="primary" onClick={showAccuseDialog}> Accuse </Button>
          {
            if (configurationId == "star_wars")
              <Button variant="contained" color="primary" onClick={showCommlinkDialog}> 
                Commlink 
              </Button>
          }
          <Divider />
          <CurrentState solver={solver} app={app} /> 
        </div>
    }
  </div>

export default MainView
