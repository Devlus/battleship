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
    this
      .channel
      .join()
      .receive("ok",(resp)=>{
        this.setState({userId: resp.user_id})
      }).receive("error", () => {
        console.log("Invalid room or userId")
      });

    this
      .channel
      .on("board", (state) => {
        this.setState({leftBoard: state.left});
        this.setState({rightBoard: state.right});
      });
  }
  leftClaimed() {
    this.channel.push("claim", {side: "left"})
  }
  rightClaimed() {
    this.channel.push("claim", {side: "right"})
  }

  render() {
    return (
      <div className="row">
        <div className={"col md-6"}>
          <Board
            board={this.state.leftBoard}
            onClaimed={this
            .leftClaimed
            .bind(this)}
            className={"col md-6"}/>
        </div>
        <div className={"col md-6"}>
          <Board
            board={this.state.rightBoard}
            onClaimed={this
            .rightClaimed
            .bind(this)}
            className={"col md-6"}/>
        </div>
      </div>
    );
  }
};