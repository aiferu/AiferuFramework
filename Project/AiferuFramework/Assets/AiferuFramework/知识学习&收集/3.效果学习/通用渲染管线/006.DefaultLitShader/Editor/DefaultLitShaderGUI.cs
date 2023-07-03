#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using System;
/*
* Introduction：
* Creator：杨公子
*/
namespace AiferuFramework.ShaderGUIEditor
{
    public class DefaultLitShaderGUI : ShaderGUI
    {
        Material target;
        MaterialEditor materialEditor;
        MaterialProperty[] properties;

        static GUIContent staticLabel = new GUIContent();

        enum SurfaceType
        {
            Opaque,
            Transparent
        };

        enum BlendingMode
        {
            Off,
            Custom,
            Alpha,
            Additive,
            Multiply
        }


        /// <summary>
        /// Main材质面板渲染
        /// </summary>
        /// <param name="materialEditor">材质编辑器的引用</param>
        /// <param name="properties">包含材质属性的数组</param>
        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            //获取当前材质编辑器的材质对象
            this.target = materialEditor.target as Material;
            this.materialEditor = materialEditor;
            this.properties = properties;
            EditorGUI.indentLevel += 2;
            DoSurfaceOptions();
            DoMain();
            DoDetailInputs();
            DoAdvancend();
            EditorGUI.indentLevel -= 2;
        }
        /// <summary>
        /// 渲染出SurfaceOpions面板
        /// </summary>
        private void DoSurfaceOptions()
        {
            GUILayout.Label("SurfaceOptions", EditorStyles.layerMaskField);

            DoSurfaceType();
            DoBlendMode();
            DoReceiveShadows();
            DoAlphaTest();
            DoCull();
        }



        /// <summary>
        /// 渲染出Main面板
        /// </summary>
        private void DoMain()
        {
            // GUILayout.
            GUILayout.Label("Main Maps", EditorStyles.layerMaskField);


            //渲染Main属性
            DoBaseMap();
            DoTextureScaleOffsetProperty();
            DoNormal();
            DoMARBlendBlock();
            DoEmission();
        }
        /// <summary>
        /// 渲染出DetailInputs面板
        /// </summary>
        private void DoDetailInputs()
        {
            GUILayout.Label("DetailInputs", EditorStyles.layerMaskField);
            MaterialProperty DetailInputsOn = FindProperty("_DetailInputsOn");
            //层级缩放
            EditorGUI.indentLevel += 2;
            materialEditor.ShaderProperty(DetailInputsOn, MakeLabel(DetailInputsOn, "是否启用细节贴图"));
            EditorGUI.indentLevel -= 2;
            if (DetailInputsOn.floatValue == 0)
            {

            }
            else
            {
                DoDetailMask();
                DoDetailAlbedoMap();
                DoDetailNormalMap();
                DoDetailTextureScaleOffsetProperty();
            }

        }
        /// <summary>
        /// 渲染出Advancend面板
        /// </summary>
        private void DoAdvancend()
        {

            GUILayout.Label("Advancend", EditorStyles.layerMaskField);

            EditorGUI.indentLevel += 2;
            //高光支持
            DoSpecularHighlightsSwitch();
            //环境反射支持
            DoEnvironmentReflsctionsSwitch();


            EditorGUI.indentLevel -= 4;
            //渲染顺序
            DoRenderQueue();
        }



        ////////////////////////////////////DoProperty/////////////////////////////////////////////



        private void DoRenderQueue()
        {
            materialEditor.RenderQueueField();
        }

        private void DoCull()
        {
            MaterialProperty Cull = FindProperty("_Cull");
            materialEditor.ShaderProperty(Cull, MakeLabel("CullMode", "剔除模式"));
        }

        private void DoAlphaTest()
        {
            // MaterialProperty AlphaTestOn = FindProperty("_AlphaTest_On");
            MaterialProperty AlphtClipThreshold = FindProperty("_AlphtClipThreshold");


            //透明度裁切阈值
            materialEditor.ShaderProperty(AlphtClipThreshold, MakeLabel(AlphtClipThreshold, "透明度裁切阈值"));
            //透明度裁切快关
            // materialEditor.ShaderProperty(AlphaTestOn, MakeLabel(AlphaTestOn, "材质是否开启透明度裁切"));
        }

        private void DoReceiveShadows()
        {
            MaterialProperty ReceiveShadows = FindProperty("_ReceiveShadows");

            //接受阴影开关
            materialEditor.ShaderProperty(ReceiveShadows, MakeLabel(ReceiveShadows, "材质是否接受阴影"));
            SetBoolKeyWord("_RECEIVE_SHADOWS_OFF", ReceiveShadows.floatValue, true);
        }

        private void DoSurfaceType()
        {


            EditorGUI.BeginChangeCheck();
            MaterialProperty SurfaceTypeProperty = FindProperty("_SurfaceType");
            materialEditor.ShaderProperty(SurfaceTypeProperty, MakeLabel(SurfaceTypeProperty, "表面类型,透明还是不透明"));
            SurfaceType surfaceType = (SurfaceType)target.GetInt("_SurfaceType");
            if (EditorGUI.EndChangeCheck())
            {

                switch (surfaceType)
                {
                    case SurfaceType.Opaque:
                        target.SetOverrideTag("RenderType", "Opaque");
                        target.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Geometry;
                        target.SetInt("_BlendingMode", (int)BlendingMode.Off);
                        //target.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        //target.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                        target.SetInt("_ZWrite", 1);
                        //target.DisableKeyword("_ALPHATEST_ON");
                        //target.DisableKeyword("_ALPHABLEND_ON");
                        //target.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                        //minRenderQueue = -1;
                        //maxRenderQueue = (int)UnityEngine.Rendering.RenderQueue.AlphaTest - 1;
                        //defaultRenderQueue = -1;
                        break;
                    case SurfaceType.Transparent:
                        target.SetOverrideTag("RenderType", "Transparent");
                        target.renderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                        target.SetInt("_BlendingMode", (int)BlendingMode.Alpha);
                        //target.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                        //target.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                        target.SetInt("_ZWrite", 0);
                        //material.DisableKeyword("_ALPHATEST_ON");
                        //material.DisableKeyword("_ALPHABLEND_ON");
                        //material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                        //minRenderQueue = (int)UnityEngine.Rendering.RenderQueue.GeometryLast + 1;
                        //maxRenderQueue = (int)UnityEngine.Rendering.RenderQueue.Overlay - 1;
                        //defaultRenderQueue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
                        break;
                }
            }

        }

        private void DoBlendMode()
        {
            MaterialProperty BlendingMode = FindProperty("_BlendingMode");
            materialEditor.ShaderProperty(BlendingMode, MakeLabel("BlendingMode", "透明度混合模式"));
            BlendingMode blendingMode = (BlendingMode)target.GetInt("_BlendingMode");

            switch (blendingMode)
            {
                case DefaultLitShaderGUI.BlendingMode.Off:
                    target.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    target.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    break;
                case DefaultLitShaderGUI.BlendingMode.Custom:
                    break;
                case DefaultLitShaderGUI.BlendingMode.Alpha:
                    target.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    target.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                    target.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    break;
                //case DefaultLitShaderGUI.BlendingMode.Premultiply:
                //    target.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                //    target.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                //    target.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                // break;
                case DefaultLitShaderGUI.BlendingMode.Additive:
                    target.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                    target.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                    target.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    break;
                case DefaultLitShaderGUI.BlendingMode.Multiply:
                    target.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                    target.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                    target.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                    target.EnableKeyword("_ALPHAMODULATE_ON");
                    break;
                default:
                    break;
            }

            EditorGUI.indentLevel += 2;
            //MaterialProperty SrcBlend = FindProperty("_SrcBlend");
            MaterialProperty SrcBlend = FindProperty("_SrcBlend");
            MaterialProperty DstBlend = FindProperty("_DstBlend");
            materialEditor.ShaderProperty(SrcBlend, MakeLabel("SrcBlend", "源颜色混合"));
            materialEditor.ShaderProperty(DstBlend, MakeLabel("DstBlend", "目标颜色混合"));
            EditorGUI.indentLevel -= 2;

        }

        private void DoDetailTextureScaleOffsetProperty()
        {
            MaterialProperty Tiling = FindProperty("_DetailTiling");
            MaterialProperty Offset = FindProperty("_DetailOffset");
            //在材质编辑器中声明一个属性容器 存入对应的属性和名称
            EditorGUI.indentLevel += 2;
            materialEditor.ShaderProperty(Tiling, MakeLabel(Tiling));
            materialEditor.ShaderProperty(Offset, MakeLabel(Offset));
            EditorGUI.indentLevel -= 2;
        }

        private void DoDetailNormalMap()
        {
            MaterialProperty DetailNormalMap = FindProperty("_DetailNormalMap");
            materialEditor.TexturePropertySingleLine(
                MakeLabel(DetailNormalMap, "细节法线(RGB)"),
                DetailNormalMap,
                //当有法线贴图时,显示法线增强按钮,没有时不显示
                DetailNormalMap.textureValue ? FindProperty("_DetailNormalMapScale") : null
                );

        }

        private void DoDetailAlbedoMap()
        {
            MaterialProperty DetailAlbedoMap = FindProperty("_DetailAlbedoMap");
            materialEditor.TexturePropertySingleLine(
                MakeLabel(DetailAlbedoMap, "细节BaseColor(RGB)"),
                DetailAlbedoMap,
                //当有法线贴图时,显示法线增强按钮,没有时不显示
                DetailAlbedoMap.textureValue ? FindProperty("_DetailAlbedoMapScale") : null
                );
        }

        private void DoDetailMask()
        {
            MaterialProperty DetailMask = FindProperty("_DetailMask");
            materialEditor.TexturePropertySingleLine(
                MakeLabel(DetailMask, "细节贴图遮罩(A)"),
                DetailMask
                );
        }

        private void DoMARBlendBlock()
        {
            GUILayout.Label("MAR Maps", EditorStyles.layerMaskField);
            MaterialProperty MARBlend = FindProperty("_MARBlend");
            materialEditor.ShaderProperty(MARBlend, MakeLabel(MARBlend));

            switch (MARBlend.floatValue)
            {

                case 0:
                    DoMetallic();
                    DoSmoothness();
                    DoOcclusion();

                    break;

                case 1:
                    DoMAR("RAM", "粗糙度(R) 环境光遮蔽(A) 金属度(M)");
                    break;
                case 2:
                    DoMAR("RMA", "粗糙度(R) 金属度(M) 环境光遮蔽(A)");
                    break;
                case 3:
                    DoMAR("ARM", "环境光遮蔽(A) 粗糙度(R) 金属度(M)");
                    break;
                case 4:
                    DoMAR("AMR", "环境光遮蔽(A) 金属度(M) 粗糙度(R)");
                    break;
                case 5:
                    DoMAR("MRA", "金属度(M) 粗糙度(R) 环境光遮蔽(A)");
                    break;
                case 6:
                    DoMAR("MAR", "金属度(M) 环境光遮蔽(A) 粗糙度(R)");
                    break;

            }
        }

        private void DoMAR(string textureName, string tooltip)
        {
            MaterialProperty _MARBlendMap = FindProperty("_MARBlendMap");
            MaterialProperty IsSmoothness = FindProperty("_IsSmoothnessMap");
            MaterialProperty SmoothnessStrength = FindProperty("_SmoothnessStrength");
            MaterialProperty OcclusionStrength = FindProperty("_OcclusionStrength");
            MaterialProperty MetallicStrength = FindProperty("_MetallicStrength");


            materialEditor.TexturePropertySingleLine(
                MakeLabel(textureName, tooltip),
                _MARBlendMap
                );

            //层级缩放
            EditorGUI.indentLevel += 2;
            materialEditor.ShaderProperty(IsSmoothness, MakeLabel(IsSmoothness, "贴图是否为粗糙度,取消勾选为光滑度"));
            materialEditor.ShaderProperty(MetallicStrength, MakeLabel(MetallicStrength));
            materialEditor.ShaderProperty(OcclusionStrength, MakeLabel(OcclusionStrength));
            materialEditor.ShaderProperty(SmoothnessStrength, MakeLabel(SmoothnessStrength));
            EditorGUI.indentLevel -= 2;

        }

        private void DoEnvironmentReflsctionsSwitch()
        {
            MaterialProperty EnvironmentReflections = FindProperty("_EnvironmentReflections");
            materialEditor.ShaderProperty(
                EnvironmentReflections,
                MakeLabel(EnvironmentReflections, "细节贴图遮罩(A)")
                );
        }

        private void DoSpecularHighlightsSwitch()
        {
            MaterialProperty SpecularHighlights = FindProperty("_SpecularHighlights");
            materialEditor.ShaderProperty(
                SpecularHighlights,
                MakeLabel(SpecularHighlights, "细节贴图遮罩(A)")
                );
        }

        private void DoEmission()
        {
            MaterialProperty EmissionMap = FindProperty("_EmissionMap");
            MaterialProperty EmissionColor = FindProperty("_EmissionColor");
            //在材质编辑器中声明一个纹理单行容器，存入名称和对应的属性,这个容器最多可容纳三个属性
            materialEditor.TexturePropertySingleLine(MakeLabel(EmissionMap, "Emission(RGB)"), EmissionMap, EmissionColor);
        }

        private void DoOcclusion()
        {
            MaterialProperty OcclusionMap = FindProperty("_OcclusionMap");
            MaterialProperty OcclusionStrength = FindProperty("_OcclusionStrength");
            //在材质编辑器中声明一个纹理单行容器，存入名称和对应的属性,这个容器最多可容纳三个属性
            materialEditor.TexturePropertySingleLine(
                MakeLabel(OcclusionMap, "Emission(RGB)"),
                OcclusionMap,
                OcclusionMap.textureValue ? OcclusionStrength : null);
        }

        private void DoBaseMap()
        {
            MaterialProperty BaseMap = FindProperty("_BaseMap");
            MaterialProperty BaseColor = FindProperty("_BaseColor");
            //在材质编辑器中声明一个纹理单行容器，存入名称和对应的属性,这个容器最多可容纳三个属性
            materialEditor.TexturePropertySingleLine(MakeLabel(BaseMap, "Albedo(RGB) and Transparency(A)"), BaseMap, BaseColor);
        }

        private void DoTextureScaleOffsetProperty()
        {
            MaterialProperty Tiling = FindProperty("_Tiling");
            MaterialProperty Offset = FindProperty("_Offset");
            //在材质编辑器中声明一个属性容器 存入对应的属性和名称
            EditorGUI.indentLevel += 2;
            materialEditor.ShaderProperty(Tiling, MakeLabel(Tiling));
            materialEditor.ShaderProperty(Offset, MakeLabel(Offset));
            EditorGUI.indentLevel -= 2;
        }

        private void DoSmoothness()
        {

            MaterialProperty SmoothnessMap = FindProperty("_SmoothnessMap");
            MaterialProperty IsSmoothness = FindProperty("_IsSmoothnessMap");
            //层级缩放
            EditorGUI.indentLevel += 2;
            materialEditor.ShaderProperty(IsSmoothness, MakeLabel(IsSmoothness, "贴图是否为粗糙度,取消勾选为光滑度"));
            EditorGUI.indentLevel -= 2;

            materialEditor.TexturePropertySingleLine(
                MakeLabel(SmoothnessMap, "Smoothness(R)"),
                SmoothnessMap,
                FindProperty("_SmoothnessStrength")
                );
        }

        private void DoMetallic()
        {
            MaterialProperty MatallicGlossMap = FindProperty("_MetallicGlossMap");
            materialEditor.TexturePropertySingleLine(
                MakeLabel(MatallicGlossMap, "MatallicGlossMap(R)"),
                MatallicGlossMap,
                FindProperty("_MetallicStrength")
                );

        }

        private void DoNormal()
        {
            MaterialProperty NormalMap = FindProperty("_BumpMap");
            MaterialProperty NormalDir = FindProperty("_NormalDir");
            materialEditor.TexturePropertySingleLine(
                MakeLabel(NormalMap),
                NormalMap,
                //当有法线贴图时,显示法线增强按钮,没有时不显示
                NormalMap.textureValue ? FindProperty("_BumpScale") : null
                );

            //在材质编辑器中声明一个属性容器 存入对应的属性和名称
            EditorGUI.indentLevel += 2;
            materialEditor.ShaderProperty(NormalDir, MakeLabel(NormalDir));
            EditorGUI.indentLevel -= 2;
        }



        //////////////////////////////////////////////////Func///////////////////////////////////////////

        /// <summary>
        /// 设置布尔类型的keyword
        /// </summary>
        /// <param name="keyword">keyword的名称</param>
        /// <param name="state">要设置的keyword的值</param>
        private void SetBoolKeyWord(string keyword, bool state)
        {
            if (state)
            {
                target.EnableKeyword(keyword);
            }
            else
            {
                target.DisableKeyword(keyword);
            }
        }

        /// <summary>
        /// 设置布尔类型的Keyword
        /// </summary>
        /// <param name="keyword">keyword的名字</param>
        /// <param name="state">要设置的keyword的值,1为true,0为false</param>
        /// <param name="negation">是否要对state取反,默认为flase</param>
        private void SetBoolKeyWord(string keyword, float state, bool negation = false)
        {
            bool stateBool = state - 0.5 > 0;
            if (negation)
            {
                stateBool = !stateBool;
            }

            if (stateBool)
            {
                target.EnableKeyword(keyword);
            }
            else
            {
                target.DisableKeyword(keyword);
            }
        }

        /// <summary>
        /// 从shader中获取名称对应的属性
        /// </summary>
        /// <param name="name">Shader中的属性名称</param>
        /// <returns></returns>
        private MaterialProperty FindProperty(string name)
        {
            return FindProperty(name, properties);
        }

        /// <summary>
        /// 生成GUIContent容器,将显示的名称和提示信息输入
        /// </summary>
        /// <param name="text">显示的名称</param>
        /// <param name="tooltip">鼠标悬停时的提示信息</param>
        /// <returns></returns>
        static GUIContent MakeLabel(string text, string tooltip = null)
        {
            staticLabel.text = text;
            staticLabel.tooltip = tooltip;
            return staticLabel;
        }

        /// <summary>
        /// 生成GUIContent容器,将显示的名称和提示信息输入
        /// </summary>
        /// <param name="property">材质属性的引用</param>
        /// <param name="tooltip">鼠标悬停时的提示信息</param>
        /// <returns></returns>
        static GUIContent MakeLabel(MaterialProperty property, string tooltip = null)
        {
            staticLabel.text = property.displayName;
            staticLabel.tooltip = tooltip;
            return staticLabel;
        }

    }
}

#endif