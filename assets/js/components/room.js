import React from "react";
import {channels} from "../socket";
import Floor from "./floor"
import Table from "./table"

export default class Room extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      code: '',
      userId: ''
    }
  }

  moveToTable(code) {
    this.setState({code: code})
  }
  onBadTable(reason){
    this.setState({code: ''})
  }

  render() {
    if (!this.state.code) {
      return <Floor onGotCode={this.moveToTable.bind(this)}/>
    } else {
      return <Table onBadTable={this.onBadTable.bind(this)} id={this.state.code} userId={this.state.userId}/>
    }
  }
}