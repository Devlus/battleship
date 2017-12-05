import React from "react";

// class!? JavaScript does't have classes Apparently ES2015 does though. And we
// can extend them.
export default class ShipBar extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      vertical: false
    };
  }
  renderButton(key) {
    if (!this.props.ships || this.props.ships[key] == null) {
      return (
        <button onClick={()=>this.props.onPlacing(key)}>{key}</button>
      )
    }
  }
  render() {
    const hide = !this.props.ships || !Object.values(this.props.ships).filter(x=>x)
    if(hide){
      return null;
    }else{
      return (
        <div>
          <div className="form form-inline mb-3">
            <label className="mr-2" >Vertical?</label>
            <input className="form-control" onChange={(e)=>this.props.onOrientationChange(e.target.checked)} type="checkbox" value={this.state.vertical}/>
          </div>
          {this.renderButton("five")}
          {this.renderButton("four")}
          {this.renderButton("three_1")}
          {this.renderButton("three_2")}
          {this.renderButton("two")}
        </div>
      );
    }
  }
};