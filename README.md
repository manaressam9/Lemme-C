<img src="https://user-images.githubusercontent.com/47770516/177051403-c452ed8f-bec9-48b1-a48c-599fabe8b39d.png" width="64" height="64" />  

# Lemme C
### Is A Smart Personal Assistance Mobile Application for Blind and Visual Impaired people
Graduation Project of Computer Engineering Department for the Year 2021/2022 at Shoubra Faculty of Engineering
## Table Of Contents
 - [About The Project](#about)
 - [Project Modules](#modules)
 - [Used Technologies](#methods)
 - [Demo](#demo)

<a name="about"></a>
## About The Project
This project aims to help blind and visually impaired people specially in Egypt and The Middle East with their daily activities by developing a <b>bilingual AI-based mobile
application </b> that is <b> voice controlled </b> and supports multiple essential features including <b> Object Recognition and Tracking, Egyptian Currency Recognition, Text Recognition </b>
and a <b> communication module </b> that connects blind and visually impaired people with the sighted who seek for a volunteering help.

> ### Application Main Features
> - Supports Multiple Services
> - Available Offline
> - Supports Arabic and English Languages
> - Enhance Accessibility (voice Controlled)

<a name="modules"></a>
## Project Modules
The Application provides Four modules <b> Egyptian Currency Recognition, Object Tracking, Arabic-English Text Recognition and Volunteering module </b>
>![modules](https://user-images.githubusercontent.com/47770516/177050473-c1933b17-2b51-4be3-83c1-b56040ae6eb6.png)

<a name="methods"></a>
## Used Technologies
- [<b>Flutter:</b>](https://docs.flutter.dev/) The application is developed in Dart programming language using Flutter Framework
- [<b>Deep Learning:</b>](https://pyimagesearch.com/2021/04/17/what-is-deep-learning/) The 3 supported modules <b> Egyptian Currency Recognition, Object Tracking and Text Recognition </b> are based on deep learning approaches 
  +  [<b>Transfer Learning: </b>](https://machinelearningmastery.com/transfer-learning-for-deep-learning/) In the Egyptian Currency Recognition module transfer learning is used to transfer the knowledge of a pretrained EfficientDet model with a custom real Egyptian currency dataset 
  + [<b> EfficientDet pretrained model: </b>](https://paperswithcode.com/method/efficientdet) In the Object Tracking module EfficientDet-Lite4 pretrained model is used to recognize objects of 80 classes 
  + [<b> Tesseract OCR Engine: </b>](https://tesseract-ocr.github.io/) In the Text Recognition module both Arabic and English tessdata pretrained models are used to recognize Arabic and English documented text
- [<b>Firebase:</b>](https://firebase.google.com/docs/firestore) Firebase platform is used to provide Cloud nosql document database that is used in the Volunteering module to store, query and sync data without needing to create backend server or rest API
- [<b>Map Box: </b>](https://www.mapbox.com/platform) Map Box platform is used in the Volunteering module to support it with maps and location services
> ![methods](https://user-images.githubusercontent.com/47770516/177051981-33a24e3e-e4f3-4e37-b172-7ec333e7866e.png)

<a name="demo"></a>
## Demo
> https://user-images.githubusercontent.com/47770516/177052010-4ee79eba-6b61-4795-8402-ea6d6f00cb49.mp4

