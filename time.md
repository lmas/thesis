
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
tickInterval 1day
axisFormat %d

%% BUG: can't use 1d milestones on fridays?? Had to use 23h instead

%% TODO: insert final presentation??

section Thesis paper
    Problem definition: 03-25, 4d

    Background: 5d

    Theory: 5d

    Method: 15d
    
    Results: 05-12, 10d

    Analysis: 05-19, 5d   

    Discussion:05-26, 5d
    Conclusion: 05-26, 5d
    Abstract: 05-26, 5d

section Work week 1
    <Weekend break>: 03-24, 1d
    Literature study: active, 03-25, 4d
    Document time plan: active, 03-27, 2d
    Run Python reference library: 1d

section Work week 2
    Develop Python prototype: 03-31, 3d
    Verify against reference: milestone, 04-02, 23h
    Develop C prototype: 4d

section Work week 3
    Verify against reference: milestone, 04-08, 23h
    Setup HW: 1d
    Finish running C prototype on HW: 04-09, 3d

section Work week 4
    Investigate wireless: 2d
    Implement wireless (client/server): 3d
    Verify transfer: milestone, 04-18, 23h

section Work week 5
    Investigate energy use: 04-21, 2d
    Implement power monitor: 3d
    Verify monitor: milestone, 04-25, 23h

section Work week 6
    Implement proper logging server:04-28,  3d
    Verify data transfers: milestone, 04-30, 23h

section Work week 7
    Setup controller host (with InfluxDB): 05-05, 1d
    Log sensor/energy data in InfluxDB: 05-05, 3d
    Setup 2nd HW unit as control: 2d

section Work week 8
    Start analysis: 5d

section Work week 9
    Finish analysis: 5d
    Cleanup results: milestone, 05-23, 23h

section Work week 10
    <Spare>: 05-26, 5d
```


# Activity log

- 2025-03-28, 6 h:
    4 h wrote the problem definition/delimitation and continued with the background,
    1 h looking up "costs required to operate larger sensor networks",
    1 h adjusting paper headings in the gantt chart.

- 2025-03-27, 7 h:
    2 h adjusting gantt chart,
    3 h sorting through last papers and looking up student theses as examples,
    2 h setting up thesis report with outline and grouping the papers.
 
- 2025-03-26, 8 h:
    Spent about 4 h sorting through and starting to read the papers,
    3 h looking for some easy planning tool with Gantt charts (eh nothing good..)
    and wrote initial gantt.
 
- 2025-03-25, 7 h:
    Read up on how to do a literature study and started searching for papers,
    using "time series anomaly detection using matrix profile".
    Tomorrow I have to sort through the 23 papers I've found.

