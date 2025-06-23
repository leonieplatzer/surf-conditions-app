spot_info <- list(
  "Pipeline" = "Pipeline on Oahu’s North Shore is one of the world’s most famous and challenging reef breaks, known for its powerful, hollow waves. It's suited for experienced surfers seeking thrilling barrels. The scenery is stunning, and the surfing culture is iconic.",
  
  "Lahaina" = "Lahaina is a historic town on Maui offering gentle reef breaks suitable for beginners and longboarders. The area is known for its friendly vibe, shops, and restaurants nearby. Surf conditions are typically mellow and great for learning.",
  
  "Honolua Bay" = "Honolua Bay is a pristine surf spot in Maui with a beautiful bay and consistent right-hand waves. The break suits intermediate to advanced surfers, especially during winter swells. The area is also protected, making it a serene place to enjoy nature.",
  
  "Waikiki" = "Waikiki Beach is famous for its gentle, rolling waves ideal for beginner surfers and longboarders. Located in Honolulu, it offers a vibrant city atmosphere alongside iconic views of Diamond Head. Surf schools and rentals make it a perfect place to start surfing.",
  
  "Sunset Beach" = "Sunset Beach on Oahu's North Shore is known for its big wave surfing during winter months and more manageable waves in summer. It attracts expert surfers looking for challenging conditions and spectacular barrels. The beach also offers beautiful sunsets and a relaxed vibe.",
  
  "Waimea Bay" = "Waimea Bay is renowned for massive winter swells attracting the world's top big wave surfers. In summer, the waves calm down, making it suitable for swimming and casual surfing. The bay is iconic in surf history and offers stunning natural beauty.",
  
  "Weligama" = "Weligama in Sri Lanka is a sandy bay perfect for beginner surfers due to its gentle waves and sandy bottom. Surf schools are abundant, and the town has a laid-back atmosphere with local cafés and markets. It’s a great place to start surfing in warm waters.",
  
  "Mirissa" = "Mirissa is known for its beautiful crescent beach with mellow waves suitable for beginners and intermediate surfers. The town is lively with good food, whale watching tours, and vibrant nightlife. It offers a perfect mix of surf and relaxation.",
  
  "Arugam Bay" = "Arugam Bay is a world-class surfing destination with a variety of waves for all skill levels, including point breaks and reef breaks. It has a chill vibe with beachfront cafés and a strong surf community. The season peaks from May to October with consistent swells.",
  
  "Hikkaduwa" = "Hikkaduwa is a popular Sri Lankan surf town featuring consistent beach breaks for all levels. The vibrant coral reefs nearby make it ideal for snorkeling when not surfing. The town buzzes with nightlife, markets, and relaxed beach bars.",
  
  "Unawatuna" = "Unawatuna offers gentle waves suitable for beginners and longboarders in a tropical bay setting. The area is known for its golden sandy beaches and calm waters, making it family-friendly. Nearby attractions include a historic fort and lively local markets.",
  
  "Midigama" = "Midigama is a quieter surf spot in Sri Lanka favored by intermediate and advanced surfers. It offers a mix of reef and point breaks with consistent waves and fewer crowds. The laid-back village vibe makes it a great retreat for focused surf sessions.",
  
  "Anchor Point" = "Anchor Point in Morocco offers a long right-hand point break with powerful waves favored by experienced surfers. The waves here can get quite large and fast, providing challenging conditions. The nearby village gives a glimpse of local Moroccan surf culture.",
  
  "Imsouane" = "Imsouane is famous for its long, mellow right-hand point break, ideal for beginner and intermediate surfers. The waves offer smooth, easy rides, often stretching several hundred meters. The town has a relaxed vibe with surf schools and cafés close to the beach, making it a great spot to learn and unwind.",
  
  "Taghazout" = "Taghazout is a bustling surf town with numerous breaks ranging from beginner-friendly beach breaks to advanced reef breaks. It has a vibrant surf culture with many surf schools, cafés, and markets. The warm climate and consistent waves attract surfers year-round.",
  
  "Safi" = "Safi is known for its powerful reef breaks that attract advanced surfers looking for heavy barrels. The area is less crowded, providing a raw surf experience. It’s a great spot to explore Moroccan surf culture away from the main tourist hubs.",
  
  "Essouira" = "Essouira combines a historic port town atmosphere with fun beach breaks suitable for all levels. Known for its strong winds, it’s also popular with windsurfers and kitesurfers. The town offers rich culture, great seafood, and artisan markets.",
  
  "Dakhla" = "Dakhla in Western Sahara offers world-class waves with a variety of beach and reef breaks for all skill levels. Its remote desert setting creates a unique surf experience with warm water and strong winds. The area is increasingly popular for kitesurfing as well.",
  
  "Nazaré" = "Nazaré is famous for some of the biggest waves in the world, attracting big wave surfers looking for extreme challenges. The powerful and massive surf is not for the faint-hearted, but the town itself is charming with great seafood. Off-season, smaller waves offer more accessible surfing.",
  
  "Ericeira" = "Ericeira is Portugal’s world surfing reserve, featuring a variety of breaks suitable for all levels. It has a rich surf culture, beautiful coastline, and quaint fishing village charm. Surf schools and shops are abundant, making it an ideal surf destination.",
  
  "Peniche" = "Peniche is a versatile surf spot known for consistent beach breaks and the famous Supertubos reef break. It caters to beginners and pros alike, with many surf schools and competitions held annually. The town is lively, with plenty of dining and accommodation options.",
  
  "Supertubos" = "Supertubos is a powerful reef break in Peniche known for its heavy barrels and fast waves. It's a hotspot for experienced surfers and hosts major international competitions. The wave offers thrilling rides but requires skill and local knowledge.",
  
  "Cascais" = "Cascais offers diverse surf conditions ranging from mellow beach breaks to more challenging reef waves. The town is charming with a marina, historic sites, and vibrant nightlife. It's a great base for exploring the Lisbon coast surf spots.",
  
  "Arrifana" = "Arrifana in the Algarve region is a beautiful beach break with consistent waves suitable for all levels. The scenic cliffs and natural surroundings create a stunning surf setting. It's a popular spot for both locals and tourists looking for relaxed surfing.",
  
  "Uluwatu" = "Uluwatu in Bali is famous for its stunning cliffside views and challenging reef breaks, ideal for intermediate to advanced surfers. The waves are powerful and hollow, attracting surfers worldwide. The area also offers a rich cultural experience with nearby temples.",
  
  "Canggu" = "Canggu is a trendy Bali hotspot with consistent beach breaks suitable for all skill levels. It boasts a vibrant café scene, nightlife, and a relaxed surf lifestyle. The waves are friendly, making it popular with longboarders and beginners.",
  
  "Medewi" = "Medewi is known for its long, mellow left-hand wave, perfect for beginners and those who enjoy long rides. It's a quiet area with fewer crowds, offering a peaceful surfing experience. The surrounding rice paddies add to the scenic charm.",
  
  "Padang Padang" = "Padang Padang is Bali’s famous reef break known for its fast, barreling waves ideal for advanced surfers. It hosts international surf contests and attracts surfers worldwide. The beach is picturesque with white sand and crystal-clear water.",
  
  "Kuta" = "Kuta Beach is Bali’s most popular beginner surf spot with gentle waves and plenty of surf schools. It offers a lively atmosphere with many shops, restaurants, and nightlife options. The long sandy beach is perfect for learning to surf in a social setting.",
  
  "Keramas" = "Keramas offers powerful right-hand reef breaks popular among experienced surfers. The spot has hosted international competitions and features consistent swell. Nearby resorts and amenities make it a comfortable surf destination.",
  
  "Santa Teresa" = "Santa Teresa in Costa Rica offers consistent beach breaks with warm water and a laid-back atmosphere. It's popular with beginners and intermediates, with many surf schools nearby. The town has great restaurants, yoga studios, and a vibrant expat community.",
  
  "Tamarindo" = "Tamarindo is a lively surf town with consistent waves suitable for beginners and intermediates. It features many surf schools, shops, and nightlife options. The sandy beach and warm waters make it a family-friendly destination.",
  
  "Nosara" = "Nosara is a tranquil surf town known for its smooth beach breaks and yoga retreats. It attracts surfers of all levels and those seeking a wellness-focused lifestyle. The beaches are pristine, and the community values sustainability.",
  
  "Dominical" = "Dominical is known for its powerful beach breaks suited to intermediate and advanced surfers. The jungle backdrop and relaxed vibe create a unique surf experience. The town offers a few local eateries and a tight-knit surf community.",
  
  "Jaco" = "Jaco Beach is a popular surf town with consistent waves suitable for beginners and intermediates. It has a lively nightlife, plenty of restaurants, and easy access from the capital city. The beach is a hub for learning to surf in Costa Rica.",
  
  "Playa Hermosa" = "Playa Hermosa is famous for its powerful waves and consistent swell, favored by experienced surfers. The beach has hosted numerous international competitions. The nearby town is small but welcoming with basic amenities.",
  
  "Bondi Beach" = "Bondi Beach is Sydney’s iconic surf spot, offering consistent beach breaks for all skill levels. The area is vibrant with cafes, shops, and a famous coastal walk. It’s a hub of surf culture and social life in Australia.",
  
  "Snapper Rocks" = "Snapper Rocks on the Gold Coast is famous for its fast, hollow waves ideal for advanced surfers. It's the starting point of the world-renowned Superbank wave and hosts major surf competitions. The beach town has a lively atmosphere and great amenities.",
  
  "Bells Beach" = "Bells Beach in Victoria is legendary for its powerful right-hand reef break and annual surfing competitions. It’s suited for experienced surfers looking for quality waves. The dramatic cliffs and natural beauty add to its appeal.",
  
  "Byron Bay" = "Byron Bay is a popular surf and lifestyle destination with a variety of beach breaks for all levels. The town is known for its laid-back vibe, vibrant arts scene, and beautiful beaches. It attracts surfers, yogis, and travelers year-round.",
  
  "Noosa Heads" = "Noosa Heads offers gentle point breaks perfect for beginners and longboarders. The national park nearby adds stunning scenery, and the town has great dining and shopping options. It’s a relaxed yet lively surf destination on Australia’s Sunshine Coast.",
  
  "Margaret River" = "Margaret River in Western Australia is famous for powerful reef and beach breaks attracting experienced surfers. The region also offers world-class wineries and stunning natural landscapes. Surfing here is often combined with exploring the local food and wine scene.",
  
  "Hossegor" = "Hossegor in France is Europe’s surfing capital, known for its powerful beach breaks and competitive surf scene. It attracts surfers of all levels with consistent waves and a vibrant town life. The beaches are lively and the atmosphere energetic.",
  
  "Biarritz" = "Biarritz offers a mix of mellow and challenging waves with a sophisticated coastal town vibe. It's popular with beginners and experienced surfers alike. The city is rich in culture, great food, and beautiful architecture.",
  
  "Lacanau" = "Lacanau is a popular French surf town with long sandy beaches and consistent beach breaks. It caters to all levels and hosts annual surf competitions. The town is lively in summer, with shops, restaurants, and a festive atmosphere.",
  
  "Seignosse" = "Seignosse is known for its powerful beach breaks and pine forests, offering a more laid-back alternative to Hossegor. It attracts surfers looking for quality waves without the crowds. The area is also popular for family-friendly beach holidays.",
  
  "Guéthary" = "Guéthary is a charming Basque surf village with consistent reef and beach breaks. It offers high-quality waves favored by experienced surfers and a relaxed coastal atmosphere. The village has excellent seafood restaurants and a rich fishing heritage.",
  
  "Anglet" = "Anglet features numerous beach breaks ideal for beginners and intermediates. The town is lively with surf shops, cafés, and a welcoming community. It’s part of the larger Basque surf region and hosts many surf events annually."
)
