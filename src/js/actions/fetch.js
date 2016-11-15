/**
 * Created by soga on 16/9/19.
 */

export const fetchAN = {
    FETCH_REQUEST : "fetch/REQUEST",
    FETCH_SUCCEED : "fetch/SUCCEED",
    FETCH_FAILED : "fetch/FAILED"
};

const action = (type, payload = {}) => ({
    type,
    ...payload
});

export const fetchData = data => action(fetchAN.FETCH_REQUEST,data);