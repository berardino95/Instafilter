//
//  ContentView.swift
//  Instafilter
//
//  Created by Berardino Chiarello on 07/06/23.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image : Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 5.0
    @State private var filterScale = 5.0
    
    @State private var showingImagePicker = false
    @State private var inputImage : UIImage?
    @State private var processedImage: UIImage?
    
    @State private var currentFilter : CIFilter = CIFilter.sepiaTone()
    let context = CIContext()
    
    @State private var showingFilterSheet = false
    @State private var showingSaveError = false
    
    var body: some View {
        NavigationView {
            VStack {
                ZStack{
                    Rectangle()
                        .fill(.secondary)
                    
                    Text("Tap to select a picture")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                    
                    image?
                        .resizable()
                        .scaledToFit()
                }
                .onTapGesture {
                    showingImagePicker = true
                }
                
                if currentFilter.inputKeys.contains(kCIInputIntensityKey) {
                    HStack{
                        Text("Intensity")
                        Slider(value: $filterIntensity)
                        //recalling applyProcessing when the filterIntensity value change, with binding property that will not appen automatically
                            .onChange(of: filterIntensity) { _ in
                                applyProcessing()
                            }
                    }
                    .padding(.vertical)
                }
                
                if currentFilter.inputKeys.contains(kCIInputRadiusKey) {
                    HStack{
                        Text("Radius")
                        Slider(value: $filterRadius, in: 0...200)
                        //recalling applyProcessing when the filterIntensity value change, with binding property that will not appen automatically
                            .onChange(of: filterRadius) { _ in
                                applyProcessing()
                            }
                    }
                    .padding(.vertical)
                }
                
                if currentFilter.inputKeys.contains(kCIInputScaleKey) {
                    HStack{
                        Text("Scale")
                        Slider(value: $filterScale, in: 0...10 )
                        //recalling applyProcessing when the filterIntensity value change, with binding property that will not appen automatically
                            .onChange(of: filterScale) { _ in
                                applyProcessing()
                            }
                    }
                    .padding(.vertical)
                }
                
                HStack{
                    Button("Change filter") {
                        showingFilterSheet = true
                    }
                    
                    Spacer()
                    
                    Button("Save button", action: save)
                        .disabled(inputImage == nil)
                    
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Instafilter")
            //call loadImage every time user select a new image from galley
            .onChange(of: inputImage) { _ in loadImage() }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(image: $inputImage)
            }
            .confirmationDialog("Select a filter", isPresented: $showingFilterSheet) {
                Group{
                    Button("Crystallize") { setFilter(CIFilter.crystallize()) }
                    Button("Edges") { setFilter(CIFilter.edges()) }
                    Button("GaussianBlur") { setFilter(CIFilter.gaussianBlur()) }
                    Button("Pixellate") { setFilter(CIFilter.pixellate()) }
                    Button("Sepia Tone") { setFilter(CIFilter.sepiaTone()) }
                    Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask()) }
                }
                Group{
                    Button("Vignette") { setFilter(CIFilter.vignette()) }
                    Button("Pointillaze") { setFilter(CIFilter.pointillize()) }
                    Button("Shade Materials") { setFilter(CIFilter.shadedMaterial()) }
                    Button("Bloom") { setFilter(CIFilter.bloom()) }
                    Button("Cancel", role: .cancel) { }
                }
            }
            .alert("Oops", isPresented: $showingSaveError) {
                Button("Ok") {}
            } message: {
                Text("Sorry, there was an error  saving your image - please check that you have allowed permission for this app to save photos")
            }
        }
        
    }
    
    //Loading image and apply the filter to it recalling the method
    func loadImage(){
        //Checking if an image is selected or inputImage is empty
        guard let inputImage = inputImage else { return }
        
        //Converting the image in a CIImage to pass it into the filter
        let beginImage = CIImage(image:inputImage)
        //passing the image into the filter
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        
        applyProcessing()
    }
    
    //Applying filter to the picture
    func applyProcessing() {
        
        let inputKeys = currentFilter.inputKeys
        
        //copying the slider filter intensity into the filter intensity
        if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterScale, forKey: kCIInputScaleKey) }
        

        //reading the output image from the filter
        guard let outputImage = currentFilter.outputImage else { return }
        
        //rendering the image with the context and convert it into a SwiftUI Image
        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }
    
    //setting another filter to the current filter from the confirmation dialog
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    
    func save(){
        guard let processedImage = processedImage else { return }
        
        let imageSaver = ImageSaver()
        
        imageSaver.successHandler = {
            print("Success!")
        }
        
        imageSaver.errorHandler = {
            print("Oops! \($0.localizedDescription)")
        }
        
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
