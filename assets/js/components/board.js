import React from "react";
import {channels} from "../socket";
import ShipBar from "./shipbar"

// class!? JavaScript does't have classes Apparently ES2015 does though. And we
// can extend them.
export default class Board extends React.Component {
  constructor(props) {
    super(props);
    this.channel = this.props.channel

    this.sizeMap = {
      five: 5, four: 4, three_1: 3, three_2: 3, two: 2
    };
    this.state = {
      grid: Array(10).fill(Array(10).fill(0)),
      placing: null,
      vertical: false,
    };
  }
  pressed(x, y) {
    debugger;
    if(this.props.board.donePlacing){
      this.props.onFire(x,y)
    }else{
      let cells = [[x, y]];
      //If placing a ship, and that ship has not been placed yet
      if (this.state.placing && !this.props.board.ships[this.state.placing]) {
        const n = this.sizeMap[this.state.placing]
        //determine ship cells
        for (let i = 1; i < n; i++) {
          if (this.state.vertical) {
            cells.push([x, y + i])
          } else {
            cells.push([x + i, y])
          }
        }
      }
      this.props.onPlaceShip(this.state.placing, cells)
    }
  }
  getCoordArray(boatMap){
    let coords = [];
    for (const key in boatMap) {
      if(boatMap[key]){
        coords = coords.concat(boatMap[key])
      }
    }
    return coords;
  }
  inList(pos, coords){
    return coords.find(x => x[0] == pos[0] && x[1] == pos[1]);
  }

  renderCell(x,y, shipCoords){
    if(this.props.enemySide){
      //Render water and misses
      if(this.inList([x,y], this.props.board.misses)){
        return (<div className={"miss"}>M</div>);  
      }
      if(this.inList([x,y], this.props.board.hits)){
        return (<div className={"hit"}>H</div>);  
      }
      if(this.props.board.donePlacing){
        return (<button onClick={() => this.pressed(x, y)} className={"btn btn-info"}>O</button>);
      }else{
        return (<div className={"water"}>O</div>);
      }
    }
    if(this.inList([x,y], shipCoords)){
      if(this.inList([x,y],this.props.board.hits)){
        return (<div className={"boat dmg"}>X</div>)
      }
      return (<div className={"boat"}>O</div>)
      } 
      else if(this.inList([x,y],this.props.board.misses)){
        return (<div className={"miss"}>M</div>);
      }else{
      if(this.props.board.donePlacing){
        return (<div className={"water"}>O</div>);
      }else{
        return (<button className="btn btn-success" onClick={() => this.pressed(x, y)}>{x},{y}</button>);
      }
    }
  }

  renderTable() {
    const coords = this.getCoordArray(this.props.board.ships);
    return (
      <table>
        {this.state.grid.map((y, j) => (
            <tr>{y.map((x, i) => (
                <td className={"cell"}>
                  {this.renderCell(i,j,coords)}
                </td>
              ))}</tr>
          ))}
      </table>
    );
  }
  orientationChange(value) {
    this.setState({vertical: value})
  }
  
  placing(shipName) {
    console.log(shipName);
    this.setState({placing: shipName})
  }
  renderShipBar(){
    if(!this.props.board.donePlacing){
      return (<ShipBar
        ships={this.props.board.ships}
        onOrientationChange={this.orientationChange.bind(this)}
        onPlacing={this.placing.bind(this)}/>);
    }
    return null;
  }

  render() {
    if (!this.props.board || !this.props.board.user) {
      return (
        <button onClick={this.props.onClaimed}>Claim Side</button>
      )
    } else {
      return (
        <div>
          {this.renderShipBar()}
          {this.renderTable()}
        </div>
      )
    }
  }
};