import './Answer.css';

import { get, post } from 'js/services/network.js';
import { validateAndRun } from 'js/services/form-utilities.js';
import { getCookie, setCookie, deleteCookie } from 'js/services/cookie.js';
import { logError } from 'js/services/error.js';
import List from '../../../Components/List/List';
import ThreePanes from '../../../Components/Layouts/ThreePanes/ThreePanes';

let questionIdCookieName = "questionId";
let currentQuestionCategory = () => /[^/]*$/.exec(window.location.href)[0];

let isRoundRobin = window.location.href.endsWith("round-robin");

function Answer(props) {
    const [categoryQuestions, setCategoryQuestions] = React.useState([]);
    const [similiarQuestions, setSimiliarQuestions] = React.useState([]);
    const [activeQuestion, setActiveQuestion] = React.useState();
    const [activeQuestionStarterIdeas, setActiveQuestionStarterIdeas] = React.useState([]);
    const [questionImages, setQuestionImages] = React.useState([]);
    const [answerText, setAnswerText] = React.useState('');

    //////////////////////////////////////////////////////////////////
    ////////// PAGE INIT /////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function getCategoryQuestions() {
        let categoryQuestions = await get(`/api/Questions/GetQuestionsWithAnswerStatusInCategory/${currentQuestionCategory()}`);
        categoryQuestions = categoryQuestions.map(transformQuestionDTO);
        if (!isRoundRobin) {
            categoryQuestions.sort((a, b) => a.questionId - b.questionId);
        }
        for (var i = 0; i < categoryQuestions.length; i++) {
            categoryQuestions[i].sortId = i
        }
        setCategoryQuestions(categoryQuestions);
    }
    React.useEffect(() => getCategoryQuestions(), []); // you have to call it this way because react's useEffect doesnt know how to handle returned promises

    function advanceToNextQuestion() {
        var _navToQuestionId = getNavToQuestionId();
        var _activeQuestion = _navToQuestionId ? getNextQuestionBasedOnCookie(_navToQuestionId) : getNextQuestionBasedOnAnswerStatus();
        updateActiveQuestion(_activeQuestion);
        scrollToQuestion(_activeQuestion.questionId);
        //document.getElementById(`questionId-${_activeQuestion.questionId}`).scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    }
    React.useEffect(() => { categoryQuestions.length > 0 && advanceToNextQuestion() }, [categoryQuestions]);

    function scrollToQuestion(activeQuestionId) {
        const container = document.querySelector('.category-questions-list .list-group');
        const activeQuestionSortId = getActiveQuestionSortId(activeQuestionId)
        const question = document.getElementById(`sortId-${activeQuestionSortId}`);
        if (container && question) {
            // Check if the screen width is greater than 991px (Bootstrap lg breakpoint)
            if (window.innerWidth > 991) {
                question.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            } else {
                container.scrollTop = question.offsetTop - container.offsetTop;
            }
        }
    }

    function getNavToQuestionId() {
        var questionId = getCookie(questionIdCookieName);
        deleteCookie(questionIdCookieName);
        var categoryContainsQuestion = categoryQuestions.filter(q => q.questionId == questionId).length > 0;
        return categoryContainsQuestion ? questionId : null;
    }

    function getActiveQuestionSortId(activeQuestionId) {
        if (activeQuestionId) {
            return categoryQuestions.find(q => q.questionId == activeQuestionId).sortId;
        }
        else {
            return null;
        }
    }

    function getNextQuestionBasedOnCookie(_navToQuestionId) {
        _navToQuestionId = parseInt(_navToQuestionId, 10);
        var _activeQuestion = categoryQuestions.filter(c => c.questionId == _navToQuestionId)[0];
        if (_activeQuestion == undefined) {
            // if nav goes wrong we could have a question questionId from another category and then the page will never load.
            logError("Failed navigating to questionId " + _navToQuestionId);

        }
        else {
            return _activeQuestion;
        }
    }

    function getNextQuestionBasedOnAnswerStatus() {
        var _activeQuestion = null;
        var unansweredQuestions = categoryQuestions.filter(c => !c.answerText);
        if (unansweredQuestions.length == 0) {
            _activeQuestion = categoryQuestions[0];
        }
        else {
            var subsequentQuestions = unansweredQuestions.filter(u => u.questionId > (activeQuestion ? activeQuestion.questionId : 0));
            _activeQuestion = subsequentQuestions.length == 0 ? unansweredQuestions[0] : subsequentQuestions[0];
        }
        return _activeQuestion;
    }

    //////////////////////////////////////////////////////////////////
    ////////// HELPERS ///////////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function transformQuestionDTO(question) {
        question.text = question.questionText;

        if (question.answerText) {
            question.pillData = {
                colorClass: "bg-secondary",
                iconClass: "bi-check2"
            }
        }
        return question;
    }

    async function saveAnswer() {
        await validateAndRun("answerForm", async () => {
            window.showLoader(window.loader.SAVING_MESSAGE);
            await post("/api/Answers/SaveAnswer", {
                questionId: activeQuestion.questionId,
                answerText: answerText
            });
            getCategoryQuestions();
            window.hideLoader();
        });
    }

    //////////////////////////////////////////////////////////////////
    ////////// NETWORK CALLS /////////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function getQuestionImages() {
        var _questionImages = await get(`/api/Questions/GetImages/${activeQuestion.questionId}`);
        setQuestionImages(_questionImages);
    }
    React.useEffect(() => activeQuestion && getQuestionImages(), [activeQuestion]);

    async function getSimiliarQuestionsWithAnswerStatus() {
        var _similiarQuestions = await get(`/api/Questions/GetSimiliarQuestionsWithAnswerStatus/${activeQuestion.questionId}`);
        _similiarQuestions = _similiarQuestions.map(transformQuestionDTO);
        setSimiliarQuestions(_similiarQuestions);
    }
    React.useEffect(() => activeQuestion && getSimiliarQuestionsWithAnswerStatus(), [activeQuestion]);

    async function getQuestionImages() {
        var _questionImages = await get(`/api/Questions/GetImages/${activeQuestion.questionId}`);
        setQuestionImages(_questionImages);
    }
    React.useEffect(() => activeQuestion && getQuestionImages(), [activeQuestion]);

    //////////////////////////////////////////////////////////////////
    ////////// MISC PAGE LOGIC ///////////////////////////////////////
    //////////////////////////////////////////////////////////////////

    function handleActiveQuestionChange() {
        // answer text
        setAnswerText(activeQuestion.answerText ? activeQuestion.answerText : "");

        // starter ideas
        var _activeQuestionStarterIdeas = activeQuestion.starterIdeas.map(starterIdea => {
            return {
                text: starterIdea
            }
        });
        setActiveQuestionStarterIdeas(_activeQuestionStarterIdeas);


    }
    React.useEffect(() => activeQuestion && handleActiveQuestionChange(), [activeQuestion]);

    function onAnswerTextChange(event) {
        setAnswerText(event.target.value);
    }

    //////////////////////////////////////////////////////////////////
    ////////// CHILD COMPONENT HANDLERS //////////////////////////////
    //////////////////////////////////////////////////////////////////

    async function updateActiveQuestion(_activeQuestion) {
        setActiveQuestion(_activeQuestion);
    }
    async function navigateToRelatedQuestion(relatedQuestion) {
        setCookie(questionIdCookieName, relatedQuestion.questionId);
        window.location.href = "/QA/Answer/" + relatedQuestion.categoryName_URLFriendly;
    }

    return (
        <ThreePanes
            id="answerWidget"
            header={
                <>
                    <h3>{activeQuestion && activeQuestion.text}</h3>
                    <h6 className="sub-header">Category: {activeQuestion && activeQuestion.categoryName}</h6>
                </>
            }
            left={
                <div className="mb-3 mb-lg-0 answer-widget-dimension answer-widget-dimension-1">
                    {
                        activeQuestion &&
                        <List
                            HeaderText="Starter Ideas"
                            ListItems={activeQuestionStarterIdeas && activeQuestionStarterIdeas} />
                    }

                    <List
                        IdProperty="questionId"
                        HeaderText="Similiar Questions"
                        ListItems={similiarQuestions}
                        OnClick={navigateToRelatedQuestion} />
                </div>
            }
            center={
                <div className="mb-3 mb-lg-0 d-flex flex-column answer-widget-dimension answer-widget-dimension-2">
                    <div className="row vision-board">
                        {
                            questionImages.map((url, i) => (
                                <div className="col-4 p-2">
                                    <img src={url} style={{ width: "100%" }} alt="" />
                                </div>
                            ))
                        }
                    </div>
                    <div className="row d-flex flex-column flex-grow-1">
                        <form id="answerForm" className="form-control flex-grow-1">
                            <textarea
                                id="answerBox"
                                className="form-control "
                                placeholder="Your answer here..."
                                value={answerText}
                                onChange={onAnswerTextChange}
                                required
                            ></textarea>
                        </form>
                    </div>
                    <div className="row">
                        <button type="button" className="btn btn-primary w-100" onClick={saveAnswer}>
                            <i className="bi bi-floppy"></i>
                        </button>
                    </div>
                </div>
            }
            right={
                <div className="answer-widget-dimension answer-widget-dimension-3 category-questions-list">
                    <List
                        IdProperty="sortId"
                        HeaderText="Questions"
                        ListItems={categoryQuestions}
                        OnClick={updateActiveQuestion}
                            ActiveItem={activeQuestion} />
                </div>
            }
        />
    );
}
ReactDOM.render(<Answer />, document.getElementById("root"));