import React from "react";
import {channels} from "../socket";
import Board from "./board";

// class!? JavaScript does't have classes Apparently ES2015 does though. And we
// can extend them.
export default class Table extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      userId: this.props.userId,
      tableId: this.props.id,
      leftBoard: {},
      rightBoard: {}
    };
    this.channel = channels.tableChannel(this.state.tableId, this.state.userId);
    this.channel.join()
      .receive("error", () => {
        console.log("Invalid room or userId")
      });

    this.channel.on("board", (state)=>{
      this.state.leftBoard = state[0];
      this.state.rightBoard = state[1];
    });
  }

  render() {
    debugger;
    return (
      <div className="row">
        <div className={"col md-6"}>
        {/* readonly={this.state.leftBoard.player != this.state.userId} */}
          <Board board={this.state.leftBoard} className={"col md-6"}/>
        </div>
        <div className={"col md-6"}>
          <Board board={this.state.rightBoard} className={"col md-6"}/>
        </div>
      </div>
    );
  }
};