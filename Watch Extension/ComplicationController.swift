//
//  ComplicationController.swift
//  Watch Extension
//
//  Created by Richard Robinson on 2020-09-04.
//

import ClockKit
import CoreData
import SwiftUI

extension UIImage {
    convenience init?(rendering string: String) {
        if let data = Data(base64Encoded: string) {
            self.init(data: data)
        } else {
            return nil
        }
    }
}

extension Event {
    var progress: Float {
        Float(end.timeIntervalSince(start) / end.timeIntervalSince(Date()))
    }
}

class ComplicationController: NSObject, CLKComplicationDataSource {
    let persistenceController = PersistenceController.shared
    
    private func getEvent(in context: NSManagedObjectContext) -> Event? {
        let fetchRequest = PersistenceController.allEventsFetchRequest()
        
        let events = try? context
            .fetch(fetchRequest)
            .compactMap(Event.init)
        

        return events?.first { !$0.isOver } ?? events?.first
    }
    
    private func getCurrentTimelineEntry(event: Event, for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let gradientIndex = UserDefaults.standard.integer(forKey: "gradientIndex")
        let gradient = Gradient.all[gradientIndex].colors.map(UIColor.init)
        
        let relativeDateTextProvider = CLKRelativeDateTextProvider(
            date: event.end,
            style: .natural,
            units: [.day, .hour, .minute, .second]
        )
        
        let emojiTextProvider = CLKSimpleTextProvider(text: event.emoji)
        let titleTextProvider = CLKSimpleTextProvider(text: event.name)
        
        let gaugeProvider = CLKTimeIntervalGaugeProvider(
            style: .fill,
            gaugeColors: gradient,
            gaugeColorLocations: nil,
            start: Date(),
            end: event.end
        )
        
        var template: CLKComplicationTemplate? = nil
        
        switch complication.family {
        case .circularSmall:
            template = CLKComplicationTemplateCircularSmallRingText(
                textProvider: emojiTextProvider,
                fillFraction: event.progress,
                ringStyle: .open
            )
            
        case .modularSmall:
            template = CLKComplicationTemplateModularSmallRingText(
                textProvider: emojiTextProvider,
                fillFraction: event.progress,
                ringStyle: .open
            )
            
        case .modularLarge:
            template = CLKComplicationTemplateModularLargeStandardBody(
                headerTextProvider: titleTextProvider,
                body1TextProvider: relativeDateTextProvider
            )
            
        case .utilitarianSmall:
            template = CLKComplicationTemplateUtilitarianSmallRingText(
                textProvider: emojiTextProvider,
                fillFraction: event.progress,
                ringStyle: .open
            )
            
        case .utilitarianLarge:
            template = CLKComplicationTemplateUtilitarianLargeFlat(
                textProvider: relativeDateTextProvider,
                imageProvider: UIImage(rendering: event.emoji).map { CLKImageProvider(onePieceImage: $0) }
            )
            
        case .extraLarge:
            template = CLKComplicationTemplateExtraLargeRingText(
                textProvider: emojiTextProvider,
                fillFraction: event.progress,
                ringStyle: .open
            )
            
        case .graphicCorner:
            template = CLKComplicationTemplateGraphicCornerGaugeText(
                gaugeProvider: gaugeProvider,
                leadingTextProvider: nil,
                trailingTextProvider: nil,
                outerTextProvider: titleTextProvider
            )
            
        case .graphicCircular:
            template = CLKComplicationTemplateGraphicCircularClosedGaugeText(
                gaugeProvider: gaugeProvider,
                centerTextProvider: emojiTextProvider
            )
            
        case .graphicBezel:
            let circularTemplate = CLKComplicationTemplateGraphicCircularClosedGaugeText(
                gaugeProvider: gaugeProvider,
                centerTextProvider: emojiTextProvider
            )
            
            template = CLKComplicationTemplateGraphicBezelCircularText(
                circularTemplate: circularTemplate,
                textProvider: titleTextProvider
            )
            
        case .graphicRectangular:
            template = CLKComplicationTemplateGraphicRectangularTextGauge(
                headerTextProvider: titleTextProvider,
                body1TextProvider: relativeDateTextProvider,
                gaugeProvider: gaugeProvider
            )
            
        case .graphicExtraLarge:
            template = CLKComplicationTemplateGraphicExtraLargeCircularStackText(
                line1TextProvider: titleTextProvider,
                line2TextProvider: relativeDateTextProvider
            )
            
        default:
            break
        }
        
        handler(template)
    }

    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "time-until-event", displayName: "Hourglass", supportedFamilies: CLKComplicationFamily.allCases)
        ]
        
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
    }

    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // Call the handler with the last entry date you can currently provide or nil if you can't support future timelines
        handler(.distantFuture)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }

    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        guard let event = getEvent(in: persistenceController.container.viewContext) else {
            handler(nil)
            return
        }
        
        getCurrentTimelineEntry(event: event, for: complication) { template in
            handler(template.map { CLKComplicationTimelineEntry(date: Date(), complicationTemplate: $0 )})
        }
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after the given date
        handler(nil)
    }

    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let fakeImage = BackgroundImage(
            urls: [:],
            id: "",
            downloadEndpoint: nil,
            color: 0,
            user: nil
        )
        
        let fakeEvent = Event(
            id: UUID(),
            name: "Trip to Greece",
            start: Date(),
            end: Date(timeIntervalSinceNow: 86000),
            emoji: "🎉",
            image: fakeImage
        )
        
        getCurrentTimelineEntry(event: fakeEvent, for: complication, withHandler: handler)
    }
}
