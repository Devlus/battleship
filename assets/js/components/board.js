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
      vertical: false
    };
  }
  pressed(x, y) {
    debugger;
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
  getCoordArray(boatMap){
    let coords = [];
    for (const key in boatMap) {
      if(boatMap[key]){
        coords = coords.concat(boatMap[key])
      }
    }
    return coords;
  }
  inBoat(pos, coords){
    return coords.find(x => x[0] == pos[0] && x[1] == pos[1]);
  }

  renderCell(x,y, coords){
    if(this.inBoat([x,y], coords)){
      return (<span>B</span>)
    }else{
      return (<button onClick={() => this.pressed(x, y)}>{x},{y}</button>);
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

  render() {
    if (!this.props.board || !this.props.board.user) {
      return (
        <button onClick={this.props.onClaimed}>Claim Side</button>
      )
    } else {
      return (
        <div>
          <ShipBar
            ships={this.props.board.ships}
            onOrientationChange={this.orientationChange.bind(this)}
            onPlacing={this.placing.bind(this)}/>
          {this.renderTable()}
        </div>
      )
    }
  }
};