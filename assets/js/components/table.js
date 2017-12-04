import React from "react";
import {channels} from "../socket";
import Board from "./board";

// class!? JavaScript does't have classes Apparently ES2015 does though. And we
// can extend them.
export default class Table extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      userId: '',
      tableId: this.props.id,
      leftBoard: {},
      rightBoard: {}
    };
    this.channel = channels.tableChannel(this.state.tableId);
    this.channel.join()
      .receive("ok",(resp)=>{
        this.setState({userId: resp.user_id})
        this.channel.push("need_state")
      }).receive("error", () => {
        console.log("Invalid room or userId")
      });

    this
      .channel
      .on("board", (state) => {
        console.log(state);
        this.setState({leftBoard: state.left});
        this.setState({rightBoard: state.right});
      });
  }
  claimed(side) {
    this.channel.push("claim", {side: side})
  }
  
  fire(side, x,y){
    console.log("firing")
    this.channel.push("fire",{side: side, pos: [x,y]})
  }
  placeShip(side, shipName, cells){
    this.channel.push("place", {side: side, name: shipName, cells: cells})
  }

  render() {
    return (
      <div className="row">
        <div className={"col md-6"}>
          <Board
            board={this.state.leftBoard}
            onClaimed={()=>this.claimed("left")}
            onFire={(x,y)=>this.fire("left",x,y)}
            onPlaceShip={(ship, cells)=>this.placeShip("left", ship, cells)}
            enemySide={this.state.leftBoard.user != this.state.userId}
            className={"col md-6"}/>
        </div>
        <div className={"col md-6"}>
          <Board
            board={this.state.rightBoard}
            onPlaceShip={(ship, cells)=>this.placeShip("right", ship, cells)}
            onClaimed={()=>this.claimed("right")}
            onFire={(x,y)=>this.fire("right",x,y)}
            enemySide={this.state.rightBoard.user != this.state.userId}
            className={"col md-6"}/>
        </div>
      </div>
    );
  }
};