// Metadata

#let title = "Time series anomaly detection for edge computing devices"
#let author = "Alex TODO"
// #let date = datetime(year: 2025, month: 2, day: 17)

#set document(
  title: title,
  author: author,
  // date: date,
)


////////////////////////////////////////////////////////////////////////////////
// Title page

#align(center, [
  // #set text(16pt)
  #heading(outlined: false, [
		#title
	])

	\

	// #author
	#columns(2, [
		By

		#author

		`mail@mail`

		#colbreak()

		With

		Luleå University of Technology

		company xxx
	])
])

TODO: new title

#pagebreak(to: "even")
#align(center, [
	[This page intentionally left blank]
])
#pagebreak()

////////////////////////////////////////////////////////////////////////////////
// Preface

#set text(size: 12pt)
#set par(justify: true, first-line-indent: 1em)

#heading(numbering: none, outlined: false, bookmarked: true, "Abstract")
// Offer a brief description of your thesis or dissertation and a concise summary
// of its conclusions. Be sure to describe the subject and focus of your work with
// clear details and avoid including lengthy explanations or opinions.

TODO 

#lorem(50)

#lorem(50)

#lorem(50)

*Keywords*: time series, matrix profile, anomaly detection, edge computing


#heading(numbering: none, outlined: false, bookmarked: true, "Preface")
// A preface is a statement of the author's reasons for undertaking the work and
// other personal comments that are not directly germane to the materials presented
// in other sections of the thesis.

TODO this paper and thanks

#lorem(50)

#lorem(50)

- #author, \
	Luleå University of Technology, 2025


#pagebreak()
#heading(numbering: none, outlined: false, bookmarked: true, "Glossary")

TODO

#set terms(separator: ": ")
/ Industry 4.0: TODO
/ Internet-of-Things: TODO
/ PLC: Programmable logic controller.
/ Edge: TODO
/ Discord anomaly: TODO
/ First: #lorem(25)
/ Second: #lorem(25)
/ Third: #lorem(25)

#pagebreak()

#heading(numbering: none, outlined: false, bookmarked: true, "Contents")
#outline(title: none, indent: 2em)

////////////////////////////////////////////////////////////////////////////////
// Introduction

#set heading(numbering: "1.")
#set page(
	numbering: "1",
  footer: context [
    #counter(page).display("1")
    #h(1fr)
    #set text(7pt)
    #author
  ]
)

// - citations-15973-Anomaly Detection_ A Survey.pdf
// 	anom. detect related to noise handling, challenges with anom. detection, detailed applications, fault/defect detection, sensor networks, pros/cons
	
// - citations-01521-Outlier Detection for Temporal Data_ A Survey.pdf
// 	other scenarios than sensors, comprehensive definitions, extra focus on streaming/sliding windows/distributed systems, environ/indust sensors and other data,

// - citations-00892-Matrix Profile I_ All Pairs Similarity Joins for Time Series__A Unifying View that Includes Motifs, Discords and Shapelets.pdf
// 	original MP algo, algo definitions, quirk with window size not power of 2?  other uses than discord discovery, batch vs streams

// - citations-00632-Progress in Outlier Detection Techniques_ A Survey.pdf
// 	many usage examples, all types, distance-based scales well/flexible, pros/cons, python tools, datasets, no MP

// - citations-00311-Smart anomaly detection in sensor systems A multi-perspective review.pdf
// 	analysis on sensors, types of sensor data/anomalies,  use at the Edge, energy usage

// - citations-00184-Detecting Sensor Faults, Anomalies and Outliers in_the Internet of Things_ A Survey on the_Challenges and Solutions.pdf
// 	IoT and sensor networks, events and errors, pros/cons of nearest neighbour, different detection strategies

// - citations-00094-Detecting Anomalies in a Time Series Database.pdf
// 	"window based discords" outperform predictive/segmentation

// - citations-00003-Dive into Time-Series Anomaly Detection_ A Decade Review.pdf
// 	large overview and theories, definitions of uni-/multivariate, anomalies, method families, matrix profile finding discord


#pagebreak()
= Introduction, ~3 pages <introduction>

// The introduction gives an overview of the area of your problems.

// - Increasing amount of data generated in the industry

With the shift towards Industry 4.0 @industry4, the manufacturing industries are
facing new challenges as they move towards decentralised processes.
This move is partly enabled by the advances with smart devices and the rise of
the Internet-of-Things.
By increasing the use of smart sensors a manufacturer can better supervise the
operation of their equipment and, for example, better predict equipment failure.

// - Need for fast data processing
// search: large amounts of sensor data in industry
// REFS:
// Big Data Challenges and Opportunities in the Hype of Industry 4.0

As _Khan et al._ notes @bigdata, sensors and PLCs are becoming the largest group
of devices that generates the most data.
And as the industries scales up their sensor networks there's an increasing need
to be able to faster process the larger amounts of data,
in order to provide real-time analysis. 

// - introduce matrix profile

This bachelor thesis will explore the use of anomaly detection on time
series data, performed on hardware-limited devices closer to the Edge.
This is an attempt at evaluating the possible usefulness of running data analysis
directly on smart sensors.
The method of anomaly detection will revolve around the Matrix Profile,
as introduced by _Yeh et al._ @matrix,
which is a family of algorithms that can be used for detecting discord anomalies,
among other uses.
They also note that "time series discords are known to be very competitive as
novelty/anomaly detectors."

The Matrix Profile is a simple algorithm with claims of being easily scaleable
@matrix and as such might offer a more performant alternative to machine learning
models or other artificial intelligence solutions that are popular as of today.
#highlight[
And being a simple algorithm the Matrix Profile might also be able to run on
smaller devices and sensors, that have too little processing power required for
running heavier AI models.
]


== Background

// The background offers the background to why you are working with your problems.

// - Growing sensor networks and increasing amounts of data in the industry
// search: industry 4.0
// REFS:
// Industry 4.0

Today the world is experiencing it's fourth industrial revolution.
If the two previous revolutions were driven by the use of electricity and
digitisation in the manufacturing industry,
then today's shift is mainly driven by the large amount of smart, modular, and
highly connected devices that forms the so called Internet-of-Things.
Dubbed as "Industry 4.0" by the team of german scientists _Dr. Lasi et al._
@industry4,
this new revolution originated from the need of increased flexibility and better 
efficiency in production systems, in order to better handle quickly shifting
market demands.

_Dr. Lasi et al._ continues in their article with,
that today's manufacturing plants can be turned into "smart factories"
thanks to technology pushing towards miniaturisation, digitisation, and automation.
These factories are utilising a growing number of sensors and digital, decentralised
systems that allows the factories to become more autonomously monitored and
controlled remotely.

// - Benefits of sensor networks
// search: sensors industry 4.0
// REFS:
// Significance of sensors for industry 4.0: Roles, capabilities, and applications

_Javaid et al._ @sensors4 also notes an increasing need of intelligent sensor
systems and networks for the smart factories.
By using autonomous sensors with higher processing capabilities,
the industry will be able to reduce their dependency on human operators and thus
reduce problems caused by the human factor, for example. 
Another benefit can be realised in the maintenance of increasingly complex systems,
as more precise detection can send alerts sooner for any failing components and
thus reduce costly maintenance downtime during production.
And with wireless sensors, monitoring is made possible for inaccessible locations
such as remote or hazardous areas.

// - Challenges with sensor networks and noisy data
// search: costs required to operate larger sensor networks???
// REFS:
// Industrial Wireless Sensor Networks: Challenges, Design Principles, and
// Technical Approaches

Of course, with increasingly larger sensor networks it also follows that the
amount of data that needs to be processed increases, as mentioned by _Javaid_.
More raw data requires communication networks with higher processing capacity.
_Gungor et al._ @sensnets suggests that the sensors should filter their data and
only send the processed data, as a step towards reducing the network overhead.
Doing so also has the possible benefit of reducing signal interference, delays,
and other anomalies that could be caused by faulty components or by the
environment's wear and tear that degrades the sensors over time.
In a later section, _Gungor_ continues with a simplified outline of a basic sensor
and notes that "... local data processing is crucial in minimizing power
consumption ...".
This has the potential of extending the lifetime of the sensors that runs on
battery, or similarly limited power sources, as well as reducing the operational
costs.

// - Application of anomaly detection to autodetect early warning signs
// search: anomaly detection temporal data
// REFS:
// Outlier Detection for Temporal Data: A Survey

Given that sensor readings are most often timestamped and thus temporal in nature
as stated by _Gupta et al._ @temporal,
then the data analysis should focus on ensuring the "temporal continuity" has
been maintained.
The analysis should flag any sudden anomalies or observed outliers in the time
series data.


// == Related work

// // The related work described work which relates to your problems.

// // Lots of examples in REF: Outlier Detection for Temporal Data: A Survey
// // - power net example
// // - wireless sensors?
// // - ai example?

// TODO

// Anomaly and outlier detection is a popular subject with a great number of studies
// and publications available.
// One of the more cited, but now older, surveys was done by _Chandola et al._ in
// 2009 [TODO], who evaluated the methods used in the previous decade.

// WRONG PAPER
// These methods revolved around the use of Machine Learning models that's common
// for today,
// such as KNN (proximity) and DBSCAN (clustering), SVM (distribution) and various
// kinds of trees, and GAN (forecasting).


== Problem definition <definition>

This thesis looks to investigate and try to answer the following questions:

- Is it possible to run the matrix profile algorithm in a limited hardware
	environment, such as a small, of-the-shelf microprocessor board, and be able
	to detect anomalies in the data streams from multiple sensors?

- If so, how efficient would this on-device-detection be in terms of sent data
	traffic (or lack of) and energy use?
	The microprocessor board should have it's performance benchmarked against a
	similar board, but which sends all sensor data continuously to a remote
	controller instead.

Positive outcomes to these questions would then indicate that sensor analysis
done close to the Edge would be beneficial to the individual sensor's lifetime
and thus reduce the overall amount of spent resources required for operating
larger sensor networks.


== Delimitations

Due to the limited time available to write a bachelor thesis,
I have constrained this thesis to only analyse the application of the matrix
profile algorithm. 
#strike[
I also have limited experience with hardware development,
so I'll only use simple and naive methods for wireless data transfer and power
monitoring.
]


== Thesis structure

The rest of the thesis has it's structure organised in the following way.
@theory introduces the theory and commonly used methods for anomaly detection.
@method walks through the implementation of the Matrix Profile algorithm and
how it's applied in the hardware.
Then the section continues with the collection of data from the hardware sensors. 
@results documents and analyses the results from the data collection,
which is then discussed --  in relation to the original problem definitions --
in @discussion.
// A final conclusion is then given in @conclusion, with suggestions for future work.


////////////////////////////////////////////////////////////////////////////////
// Theory

#pagebreak()
= Theory, ~7 pages <theory>

// - citations-00242-Revisiting Time Series Outlier Detection_ Definitions and Benchmarks.pdf
// 	definitions of outliers, benchmarks, comparison of discord shows better results than deep learning, problems with normalisation
// 	use in: theory, results

// - citations-00008-A Robust and Explainable Data-Driven Anomaly_Detection Approach For Power Electronics.pdf
// 	detailed anomalies, MP details, better than transformer model
// 	use in: weak, analysis? theory?

TODO

- anomaly detection
- discords
- distance based/nearest neighbour
- cache optimisation
- problems with normalisation


////////////////////////////////////////////////////////////////////////////////
// Method

#pagebreak()
= Method, ~8 pages <method>

// The implementation describes how you have implemented a solution to your problems.

// - citations-00060-Matrix Profile XXIV_ Scaling Time Series Anomaly Detection_to Trillions of Datapoints and Ultra-fast Arriving Data Streams.pdf
// 	DAMP algo, fast/high scale, complexity, learning warning threshold
// 	use in: theory, method
//
// - citations-00006-Anomaly Detection on IT Operation Series_via Online Matrix Profile.pdf
// 	detailed cache optimisation for MP, complexity and problems with normalisation, positive results
// 	use in: theory, method
//
// - need references for HW, wireless transfer, power monitoring, data logging

TODO

- DAMP algo details
- why python first then C
- verifying implementation against references
- caching?
- handling normalisation issues?
- hardware setup
- collecting sensor data
- wireless
- power monitoring

////////////////////////////////////////////////////////////////////////////////
// Results

// The evaluation evaluates whether you have actually solved your problems.

#pagebreak()
= Results, ~10 pages <results>

TODO

== Analysis

TODO

////////////////////////////////////////////////////////////////////////////////
// Discussion

// The discussion discusses each individual problem, how you addressed it, alternative solutions and shortcomings, etc.

#pagebreak()
= Discussion <discussion>

TODO

////////////////////////////////////////////////////////////////////////////////
// Conclusion

// The conclusions and future work describes the final outcome of how you solved your problems and what is left to do.

== Conclusion

TODO

== Future work

TODO

////////////////////////////////////////////////////////////////////////////////
// References

#pagebreak()
= References

#bibliography(
	"references.yml",
	style: "ieee",
	title: none,
)

////////////////////////////////////////////////////////////////////////////////
// Appendices

#pagebreak()
= Appendix A

TODO matlab code and appendix b the prototype?

