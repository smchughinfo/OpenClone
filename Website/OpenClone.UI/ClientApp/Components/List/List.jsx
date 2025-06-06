/*
    CSS REQUIREMENTS:
        - must be placed inside of a .d-flex .flex-column

*/

import './List.css';

function List(props) {
    var idProperty = props.IdProperty;
    var isLinkList = props.OnClick !== undefined;
    var itemClass = "list-group-item d-flex justify-content-between align-items-start";

    function renderPill(item) {
        if (item.pillData) {
            return (
                <span class={"badge rounded-pill " + item.pillData.colorClass}>
                    <i className={"bi  " + item.pillData.iconClass}></i>
                </span>
            )
        }
    }

    function renderLinkList() {
        return (
            <div className="list-group"> {
                props.ListItems.map((item, i) => {
                    var activeState = (props.ActiveItem && (item[idProperty] == props.ActiveItem[idProperty])) ? " active" : "";
                    return (
                        <a key={i}
                            id={`${idProperty}-${item[idProperty]}`}
                            className={itemClass + activeState}
                            onClick={() => { props.OnClick(item) }}
                            href="#"
                            aria-current="true">
                            <div className={"ms-2 me-auto " + (item.subtext ? "text-start" : "")}>
                                {item.text}
                            </div>
                            {renderPill(item)}
                        </a>
                    );
                })
            }
            </div>
        )
    }

    function renderStaticList() {
        return (
            <ul className="list-group"> {
                props.ListItems.map((item, i) => {
                    return (
                        <li key={i}
                            className={itemClass}>
                            <div className={"ms-2 me-auto " + (item.subtext ? "text-start" : "")}>
                                {item.text}
                            </div>
                            {renderPill(item)}
                        </li>
                    );
                })
            }
            </ul>
        )
    }


    return (
        <div className="list card">
            <h5 className="card-header">{props.HeaderText}</h5>
            <div className="card-body p-0">
                { isLinkList ? renderLinkList() : renderStaticList() }
            </div>
        </div>
    );
}

export default List;
