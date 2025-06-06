import './ConfirmDialog.css';

function ConfirmDialog(props) {
    const [inputValue, setInputValue] = React.useState('');

    React.useEffect(() => {
        const modalElement = document.getElementById('confirmDialog');
        const modal = new window.bootstrap.Modal(modalElement);
        modal.show();

        const handleHide = () => {
            modalElement.removeEventListener('hidden.bs.modal', handleHide);
            document.body.removeChild(modalElement);
        };

        modalElement.addEventListener('hidden.bs.modal', handleHide);

        return () => {
            modalElement.removeEventListener('hidden.bs.modal', handleHide);
        };
    }, []);

    const handleChange = (e) => {
        setInputValue(e.target.value);
    };

    return (
        <div className="modal fade" id="confirmDialog" tabIndex="-1" aria-labelledby="chooserModalLabel" aria-hidden="true">
            <div className="modal-dialog openclone-modal-y-position">
                <div className="modal-content">
                    <div className="modal-header">
                        <h5 className="modal-title" id="chooserModalLabel">{ props.header }</h5>
                        <button type="button" className="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>

                    {props.confirmationText && (
                        <>

                            <div className="modal-body">
                                <p>{props.confirmationText}</p>

                                {props.challenge && (
                                    <>
                                        <input
                                            type="text"
                                            value={inputValue}
                                            onChange={handleChange}
                                            className="form-control"
                                        />
                                    </>
                                )}
                            </div>

                        </>
                    )}


                    <div className="modal-footer">
                        <button type="button" className="btn btn-secondary" data-bs-dismiss="modal" onClick={props.onCancel}>Cancel</button>
                        <button
                            type="button"
                            className="btn btn-primary"
                            data-bs-dismiss="modal"
                            onClick={props.onConfirm}
                            disabled={props.challenge && (inputValue !== props.challenge)}
                        >
                            Okay
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}

export function showConfirmDialog(options) {
    // all possible options should get normalized here
    options = {
        header: options.header ? options.header : "Please Confirm",
        confirmationText: options.confirmationText ? options.confirmationText : "",
        challenge: options.challenge ? options.challenge : false,
        onConfirm: options.onConfirm,
        onCancel: options.onCancel
    };

    const div = document.createElement('div');
    document.body.appendChild(div);

    const handleConfirm = () => {
        options.onConfirm();
        ReactDOM.unmountComponentAtNode(div);
    };

    const handleCancel = () => {
        if (options.onCancel) {
            options.onCancel();
        }
        ReactDOM.unmountComponentAtNode(div);
    };

    ReactDOM.render(
        <ConfirmDialog
            header={options.header}
            confirmationText={options.confirmationText}
            challenge={options.challenge}
            onConfirm={handleConfirm}
            onCancel={handleCancel}
        />,
        div
    );
}
