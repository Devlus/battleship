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
            onPlaceShip={(ship, cells)=>this.placeShip("left", ship, cells)}
            className={"col md-6"}/>
        </div>
        <div className={"col md-6"}>
          <Board
            board={this.state.rightBoard}
            onPlaceShip={(ship, cells)=>this.placeShip("right", ship, cells)}
            onClaimed={()=>this.claimed("right")}
            className={"col md-6"}/>
        </div>
      </div>
    );
  }
};