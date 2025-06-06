import './ThreePanes.css';

function ThreePanes(props) {
    return (
        <div id={props.id} className="container-fluid">
            <div className="row">
                <div className="col-12">
                    <div className="card text-center">
                        {props.header && (
                            <div className="card-header">
                                {props.header}
                            </div>
                        )}
                        <div className="card-body">
                            <div className="row">
                                <div className={`left-pane col-12 col-lg-3 order-2 order-lg-1`}>
                                    {props.left}
                                </div>
                                <div className={`center-pane col-12 col-lg-6 order-1 order-lg-2`}>
                                    {props.center}
                                </div>
                                <div className={`right-pane col-12 col-lg-3 order-3 order-lg-3`}>
                                    {props.right}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default ThreePanes;
