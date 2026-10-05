import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/app_services.dart';
import '../../core/models/plant.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  @override State<ScannerScreen> createState()=>_ScannerScreenState();
}
class _ScannerScreenState extends State<ScannerScreen> {
  late Future<List<Plant>> _plants;
  String? _selectedId,_imagePath,_error;
  bool _analyzing=false;
  final _picker=ImagePicker();
  @override void initState(){super.initState();_plants=_loadPlants();}
  Future<List<Plant>> _loadPlants() async {
    final plants=await AppServices.garden.getPlants();
    if(_selectedId==null&&plants.isNotEmpty)_selectedId=plants.first.id;
    return plants;
  }
  Plant? _selectedPlant(List<Plant> plants){for(final p in plants){if(p.id==_selectedId)return p;}return null;}
  Future<void> _pick(ImageSource source) async {
    if(_analyzing)return;
    final image=await _picker.pickImage(source:source,imageQuality:90,maxWidth:2048,maxHeight:2048);
    if(image==null||!mounted)return;
    setState(()=>_imagePath=image.path);
    setState(()=>_error=null);
  }
  Future<void> _analyze() async {
    if(_imagePath==null){setState(()=>_error='Choose a photo first.');return;}
    final plants=await _plants; final plant=_selectedPlant(plants);
    if(plant==null){setState(()=>_error='Add a plant before scanning.');return;}
    setState(()=>{_analyzing=true,_error=null});
    try {
      final user=await AppServices.auth.currentUser();
      if(user==null)throw StateError('Sign in required.');
      final reference=await AppServices.imageStorage.uploadPlantImage(filePath:_imagePath!,userId:user.id);
      final result=await AppServices.diagnosis.diagnose(imagePath:_imagePath!,imageReference:reference,plantId:plant.id,plantHint:plant.name);
      if(mounted)Navigator.pushNamed(context,AppRouter.diagnosis,arguments:result);
    } catch (_) {
      if(mounted)setState(()=>_error='We could not analyze this photo. Try a clearer image.');
    } finally {if(mounted)setState(()=>_analyzing=false);}
  }
  @override Widget build(BuildContext context)=>Scaffold(
    body:SafeArea(child:FutureBuilder<List<Plant>>(future:_plants,builder:(context,snapshot){
      if(snapshot.connectionState==ConnectionState.waiting)return const Center(child:CircularProgressIndicator());
      final plants=snapshot.data??const <Plant>[]; final plant=_selectedPlant(plants);
      return ListView(padding:const EdgeInsets.fromLTRB(16,10,16,24),children:[
        Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Scan',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900)),Text('AI plant health check',style:TextStyle(color:PlantCareColors.muted))])),IconButton(tooltip:'Health history',onPressed:()=>Navigator.pushNamed(context,AppRouter.diagnosisHistory),icon:const Icon(Icons.history_rounded))]),
        const SizedBox(height:16),const Text('SELECT PLANT',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,letterSpacing:.7,color:PlantCareColors.primary)),const SizedBox(height:8),
        if(plants.isEmpty)Card(child:ListTile(leading:const Icon(Icons.eco_outlined,color:PlantCareColors.primary),title:const Text('No plants yet',style:TextStyle(fontWeight:FontWeight.w800)),subtitle:const Text('Add a plant so this scan can be saved to your garden.'),trailing:TextButton(onPressed:()=>Navigator.pushNamed(context,AppRouter.addPlant),child:const Text('ADD'))))
        else DropdownButtonFormField<String>(initialValue:plant?.id,decoration:const InputDecoration(prefixIcon:Icon(Icons.eco_outlined),hintText:'Choose from My Plants'),items:[for(final p in plants)DropdownMenuItem(value:p.id,child:Text(p.name))],onChanged:_analyzing?null:(v)=>setState(()=>_selectedId=v)),
        const SizedBox(height:18),const Text('PHOTO',style:TextStyle(fontSize:12,fontWeight:FontWeight.w900,letterSpacing:.7,color:PlantCareColors.primary)),const SizedBox(height:8),
        Container(height:300,decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),border:Border.all(color:PlantCareColors.border)),child:_analyzing?const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[CircularProgressIndicator(),SizedBox(height:14),Text('Analyzing plant…',style:TextStyle(fontWeight:FontWeight.w800)),SizedBox(height:4),Text('Checking visual disease signals',style:TextStyle(color:PlantCareColors.muted,fontSize:12))])):_imagePath==null?const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.document_scanner_outlined,size:48,color:PlantCareColors.primary),SizedBox(height:10),Text('Add a clear plant photo',style:TextStyle(fontSize:17,fontWeight:FontWeight.w800)),SizedBox(height:4),Text('Good light • leaf in focus • affected area visible',style:TextStyle(color:PlantCareColors.muted,fontSize:12))])):Stack(fit:StackFit.expand,children:[ClipRRect(borderRadius:BorderRadius.circular(12),child:Image.file(File(_imagePath!),fit:BoxFit.cover)),Positioned(top:8,right:8,child:IconButton.filledTonal(onPressed:()=>setState(()=>_imagePath=null),icon:const Icon(Icons.close)))])),
        if(_error!=null)Padding(padding:const EdgeInsets.only(top:8),child:Text(_error!,textAlign:TextAlign.center,style:const TextStyle(color:PlantCareColors.danger))),
        const SizedBox(height:12),Row(children:[Expanded(child:OutlinedButton.icon(onPressed:_analyzing?null:()=>_pick(ImageSource.gallery),icon:const Icon(Icons.photo_library_outlined),label:Text(_imagePath==null?'Gallery':'Change'))),const SizedBox(width:8),Expanded(child:FilledButton.icon(onPressed:_analyzing?null:()=>_pick(ImageSource.camera),icon:const Icon(Icons.camera_alt_outlined),label:Text(_imagePath==null?'Camera':'Retake')))]),
        if(_imagePath!=null&&!_analyzing)Padding(padding:const EdgeInsets.only(top:8),child:SizedBox(width:double.infinity,child:FilledButton.icon(onPressed:plant==null?null:_analyze,icon:const Icon(Icons.center_focus_strong),label:const Text('ANALYZE PHOTO')))),
        const SizedBox(height:8),const Text('PlantCare AI provides an AI-assisted result. Review low-confidence results carefully.',textAlign:TextAlign.center,style:TextStyle(color:PlantCareColors.muted,fontSize:11))
      ]);
    })),
    bottomNavigationBar:const AppBottomNav(selectedIndex:2),
  );
}