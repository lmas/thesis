
# Proposed time plan

- Week 1: Find and study previous work done, run reference implementation (done in Python, for example) on artificial data.
- Week 2: Setup the first board, start developing C implementation of matrix profile.
- Week 3: Finish implementation and test it on the board.
- Week 4: Investigate and implement sending data wirelessly (preferable) from the board.
- Week 5: Investigate how to measure energy usage, setup extra sensors if required.
- Week 6: Finish both investigations and apply new implementations on the board.
- Week 7: Setup controller and InfluxDB, start collecting sensor data and energy usage.
- Week 8: Setup second board without matrix profile, let it send full sensor data and start analysing the statistics.
- Week 9: Finish the analysis and comparison of both boards, write up the results.
- Week 10: Intentional left as a spare, in case of problems.


# Planned schedule

```mermaid
gantt
dateFormat  MM-DD
excludes saturday, sunday
weekday monday
tickInterval 1week

%% TODO: insert final presentation??

section Thesis paper
    Problem definition: 03-28, 6d
    Motivation: 03-31, 5d
    Background: 04-07, 10d
    Method: 15d
    Results/Analysis: 10d
    Discussion: 5d
    Conclusion: 05-26, 5d
    Abstract: 05-26, 5d

section Work week 1
    Extra weekend break: 03-24, 1d
    Literature study: active, 03-25, 4d
    Document time plan: active, 03-27, 2d
    Run Python ref. library: 1d

section Work week 2
    Develop Python version: 03-31, 3d
    Verify against reference: 04-02, 1d
    Develop C version: 4d

section Work week 3
    Verify against reference: 04-08, 1d
    Setup HW: 1d
    Finish C implementation: 04-09, 3d

section Work week 4
    Investigate wireless: 2d
    Implement wireless (client/server): 3d
    Verify transfer: 04-18, 1d

section Work week 5
    Investigate energy use: 2d
    Implement power monitor: 3d
    Verify monitor: 04-25, 1d

section Work week 6
    Implement proper logging server: 3d
    Verify data transfers: 04-30, 1d
    <Extra time if needed to finish>: 2d

section Work week 7
    Setup controller host (with InfluxDB): 1d
    Log sensor/energy data in InfluxDB: 2d
    %% TODO
    <Unintentional left empty?>: 2d

section Work week 8
    %% TODO
    Setup 2nd unit: 2d
    Start analysing collected data: 3d

section Work week 9
    %% TODO
    Finish analysis: 5d

section Work week 10
    <Left as extra>: 5d
```


# Activity log

- 2025-03-26, 8h: Spent about 4h sorting through and starting to read the papers, spent around 3h looking for some easy planning tool with Gantt charts (eh nothing good..) and wrote initial gantt.
- 2025-03-25, 7h: Read up on how to do a literature study and started searching for papers, mostly focused on "time series anomaly detetion using matrix profile". Tomorrow I will have to sort through the 23 papers I've found.

