Alcohol Label Verifier

A prototype web application that uses OCR to extract text from alcohol beverage labels and checks them against core TTB (Alcohol and Tobacco Tax and Trade Bureau) requirements.

Live Application
https://alcohollabelverification-production-0201.up.railway.app

How to Use

1. Go to the link above
2. Find Github file named "genericPracticeLabel.jpg"
3. Click "Upload and Check Label" or drag and drop image file named "genericPracticeLabel.jpg"
4. Wait for the system to process the image
5. Review the Pass/Fail result along with the detailed breakdown of detected requirements

Technical Approach & Tools Used

- Backend: ASP.NET Core (.NET 8) Web API
- OCR: Tesseract (open-source, runs locally)
- Frontend: HTML + vanilla JavaScript (built with assistance from Copilot)
- Development Support: Used Grok for architecture guidance, logic refinement, and specific prompts when needed

Limitations

- OCR accuracy depends heavily on image quality, lighting, and font clarity
- Brand name detection uses heuristics and may not work perfectly on highly stylized labels
- Optimized for English-language labels

How It Addresses the Requirements
The application focuses on the main TTB label elements mentioned in the assessment (Government Warning, Alcohol Content, Brand Name, Net Contents, etc.) and provides clear, structured results for compliance review.

