import './Edit.css';

import { get, post } from 'js/services/network.js';
import { logError } from 'js/services/error.js';
import { formatDateTime } from 'js/idk-where-these-go/utils.js'
import { validateAndRun } from 'js/services/form-utilities.js';

function Edit(props) {
    //alert("on this page you should have tooltips for the buttons, a confirm before the question is deleted with a don't ask me again which sets a cookie for this particular dialog (e.g. pass a sting into the confirm dialog and it will check for that string - if the strin exists it will just not display itself and return true or whatever it needs to do), and the delete icon should be a trash can")

    const [answers, setAnswers] = React.useState([]);
    const [customQuestion, setCustomQuestion] = React.useState("");
    const [customAnswer, setCustomAnswer] = React.useState("");

    //////////////////////////////////////////////////////////////////
    ////////// PAGE INIT /////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function getAllAnswers(supressLoader) {
        if (!supressLoader) window.showLoader();
        let _answers = await get(`/api/Answers/GetAllAnswers`);
        setAnswers(_answers);
        if (!supressLoader) window.hideLoader();
    }
    React.useEffect(() => getAllAnswers(), []); // you have to call it this way because react's useEffect doesnt know how to handle returned promises

    function onAnswerTextChange(index, event) {
        const newAnswers = answers.map((answer, i) => {
            if (i === index) {
                return { ...answer, answerText: event.target.value };
            }
            return answer;
        });
        setAnswers(newAnswers);
    }

    async function updateAnswer(index) {
        await validateAndRun("customAnswer-" + index, async () => {
            var answerToSave = answers[index];
            window.showLoader(window.loader.SAVING_MESSAGE);
            await post("/api/Answers/SaveAnswer", {
                questionId: answerToSave.questionId,
                answerText: answerToSave.answerText
            });
            await getAllAnswers(true);
            window.hideLoader();
        });
    }

    async function deleteAnswer(index) {
        window.showLoader(window.loader.DELETING_MESSAGE);
        var answerToDelete = answers[index];
        await post("/api/Answers/DeleteAnswer", answerToDelete.questionId);
        await getAllAnswers(true);
        window.hideLoader();
    }
    async function addCustomQA() {
        await validateAndRun("addCustomQAForm", async () => {
            window.showLoader(window.loader.SAVING_MESSAGE);
            await post("/api/Answers/SaveCustomQA", {
                questionText: customQuestion,
                answerText: customAnswer
            });
            setCustomQuestion("");
            setCustomAnswer("");
            getAllAnswers();
            window.hideLoader();
        });
    }

    return (
        <div className="container-fluid">
            <ul className="list-group list-group-flush">
                <li className="list-group-item p-md-5">
                    <div className="row">
                        <div className="col-10 ps-0">
                            <h3>
                                New Custom (User Defined)
                            </h3>
                        </div>
                        <div className="col-2 text-end pe-0">
                            <button
                                className="btn btn-primary btn-sm"
                                onClick={addCustomQA}>
                                <i className="bi bi-plus-square"></i>
                            </button>
                        </div>
                    </div>
                    <form id="addCustomQAForm" className="row">
                        <input
                            type="text"
                            class="form-control mb-2"
                            placeholder="Your custom question here..."
                            value={customQuestion}
                            onChange={(event) => setCustomQuestion(event.target.value)}
                            required
                        />
                        <textarea
                            className="form-control flex-grow-1"
                            placeholder="Your answer here..."
                            value={customAnswer}
                            onChange={(event) => setCustomAnswer(event.target.value)}
                            required
                        ></textarea>
                    </form>
                </li>
            </ul>
            <hr />
            <div className="row">
                <h3 class="ps-3 ps-md-5">
                    All Answers
                </h3>
            </div>
            <ul className="list-group list-group-flush">
                {
                    answers.map((answer, i) => (
                        <li className="list-group-item p-md-5 pt-5 pb-5" key={i}>
                            <div className="row">
                                <div className="col-10 ps-0">
                                    <h5 className="text-primary">
                                        {answer.questionText}
                                    </h5>
                                </div>
                                <div className="col-2 text-end pe-0 pb-1">
                                    <button
                                        className="btn btn-primary btn-sm"
                                        onClick={() => updateAnswer(i)}>
                                        <i className="bi bi-floppy"></i>
                                    </button>
                                    <button
                                        className="btn btn-danger btn-sm ms-1"
                                        onClick={() => deleteAnswer(i)}>
                                        <i className="bi bi-x-square"></i>
                                    </button>
                                </div>
                            </div>
                            <div className="row">
                                <form id={"customAnswer-" + i}>
                                    <textarea
                                        className="form-control flex-grow-1"
                                        placeholder="Your answer here..."
                                        value={answer.answerText}
                                        onChange={(event) => onAnswerTextChange(i, event)}
                                        required
                                    ></textarea>
                                </form>
                            </div>
                            <div className="row small text-muted">
                                <div class="col-6 ps-0 text-start">
                                    Question Category:&nbsp;
                                    <a
                                        href={`/QA/Answer/${answer.categoryName_URLFriendly}`}
                                        class="subdued-link">
                                        {answer.categoryName}
                                    </a>
                                </div>
                                <div class="col-6 pe-0 text-end">
                                    Answered {formatDateTime(answer.answerDate)}
                                </div>
                            </div>
                        </li>
                    ))
                }
            </ul>
        </div>
    );
}

ReactDOM.render(<Edit />, document.getElementById("root"));
