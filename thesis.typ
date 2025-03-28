// Metadata

#let title = "Time series anomaly detection for edge computing devices"
#let author = "Alex TODO"
// #let date = datetime(year: 2025, month: 2, day: 17)

TODO

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
// #pagebreak(to: "odd")
#pagebreak()

#align(center, [
	[This page intentionally left blank]
])
#pagebreak()

////////////////////////////////////////////////////////////////////////////////
// Preface

// #set text(size: 10pt)
#set par(justify: true, first-line-indent: 1em)
#heading(numbering: none, outlined: false, bookmarked: true, "Preface")

TODO this paper and thanks
#lorem(50)

#lorem(50)

#lorem(50)

#author

Luleå University of Technology, 2025

#heading(numbering: none, outlined: false, bookmarked: true, "Abstract")

TODO 
#lorem(50)

#lorem(50)

#lorem(50)

Keywords: time series, matrix profile, anomaly detection, edge computing
#pagebreak()

#heading(numbering: none, outlined: false, bookmarked: true, "Glossary")

TODO

#set terms(separator: ": ")
/ Edge computing: TODO
/ First: #lorem(25)
/ Second: #lorem(25)
/ Third: #lorem(25)

#pagebreak()

#heading(numbering: none, outlined: false, bookmarked: true, "Contents")
#outline(title: none, indent: 2em)
#pagebreak()

////////////////////////////////////////////////////////////////////////////////
// Styling

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

// Add inline bibliography
#let bibitem(body) = figure(kind: "bibitem", body, supplement: none)

// Display the list of references.
#show figure.where(kind: "bibitem"): it => {
	align(left,
		box(width: 2em, it.counter.display("[1]")) + it.body + parbreak()
	)
}

// Display citation
#show ref: it => {
	let e = it.element
	if e != none and e.func() == figure and e.kind == "bibitem" {
		// Display a citation
		numbering("[1]", ..e.counter.at(e.location()))
	} else {
		it // Displays the original reference
	}
}

////////////////////////////////////////////////////////////////////////////////
// Introduction

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


= Introduction, ~3 pages <introduction>

// The introduction gives an overview of the area of your problems.

TODO

with an increasing usage of sensors and sensor networks sees an increasing amount
of data being transfered, sdtored and analysed.

// TODO: need working ref using "increased use of sensors in industry 4.0"


== Background

// The background offers the background to why you are working with your problems.

// USED REFS:
// Gungor: citations-02258-Industrial Wireless Sensor Networks_ Challenges.pdf

Gungor et al [TODO] outlines a list of challenges associated with running sensor
networks in an industrial setting.
Small sensors have a limited amount of resources available, such as CPU 
and memory allocation. Most often the sensors also runs on battery power or similar,
which puts a hard limit on the sensors' lifetime.
The environment itself can be a limiting factor, with wear and tear degrading the
data readings from a sensor or causing interference or delays during data transfers.
The list continues with other issues inherit with running wireless devices,
such as security and time synchronisation, but these are out of scope for this thesis.
// TODO: ref other studies/surveys on security in industry 4.0?

In a later section, Gungor then outlines the (simplified) architecture of a basic
sensor and notes that "... local data processing is crucial in minimizing power
consumption ...".
Given that sensor data is temporal, it should be possible to run data analysis directly

// TODO: finish this paragraph, ref the temporal survey and continue into motivation


== Motivation

//  The motivation gives a motivation to why you are solving the problems.

TODO


== Related work

// The related work described work which relates to your problems.


TODO


== Problem definition

With this project I would like to investigate and try to answer the following questions:

- Is it possible to run the matrix profile algorithm in a limited hardware environment,
	such as a small, of-the-shelf microprocessor board, and be able to detect anomalies
	in the data streams from multiple sensors?

- If so, how efficient would this on-device-detection be in terms of sent data traffic
	(or lack of) and energy use?
	The microprocessor board should have it's performance benchmarked against a similar board,
	but which sends all sensor data continuously to a remote controller instead.

Positive outcomes to these questions would then indicate that sensor analysis done
close to the Edge would be beneficial to the individual sensor's lifetime and thus
reduce the overall amount of spent resources required for operating larger sensor networks.


== Delimitations

Due to the limited time available to write a bachelor thesis,
I have constrained this thesis to only analyse the application of the matrix profile
algorithm. 
I also have limited experience with hardware development,
so I'll only use simple and naive methods for wireless data transfer and power
monitoring.


== Thesis structure

The rest of the thesis has it's structure organised in the following way.
@theory introduces the theory and commonly used methods for anomaly detection.
@method walks through the implementation of the Matrix Profile algorithm and
how it's applied in the hardware.
Then the section continues with the collection of data from the hardware sensors. 
@results documents and analyses the results from the data collection,
which is then discussed, in relation to the original problem definitions, in @discussion.
A final conclusion is then given in @conclusion, with suggestions for future work.


////////////////////////////////////////////////////////////////////////////////
// Theory

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

= Results, ~10 pages <results>

TODO

== Analysis

TODO

////////////////////////////////////////////////////////////////////////////////
// Discussion

// The discussion discusses each individual problem, how you addressed it, alternative solutions and shortcomings, etc.

= Discussion <discussion>

TODO

////////////////////////////////////////////////////////////////////////////////
// Conclusion

// The conclusions and future work describes the final outcome of how you solved your problems and what is left to do.

= Conclusion <conclusion>

TODO

== Future work

TODO

////////////////////////////////////////////////////////////////////////////////
// References

= References

TODO

// #bibitem[
// 	Eamonn Keogh,
// 	_The UCR Matrix Profile Page_,
// 	undated,
// 	https://www.cs.ucr.edu/~eamonn/MatrixProfile.html
// ] <matrix>


////////////////////////////////////////////////////////////////////////////////
// Appendices

= Appendix A

TODO
