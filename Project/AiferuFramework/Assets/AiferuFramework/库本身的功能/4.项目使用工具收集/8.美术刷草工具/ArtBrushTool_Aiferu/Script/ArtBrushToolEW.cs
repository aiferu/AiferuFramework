#if UNITY_EDITOR
using UnityEngine;
using UnityEngine.SocialPlatforms;
using UnityEditor;
using System.Collections.Generic;
using System.Numerics;

namespace AiferuFramework.ArtBrushTool
{
    /// <summary>
    /// 美术刷草工具
    /// </summary>
    public class ArtBrushToolEW : EditorWindow
    {
        #region 基础数据
        /// <summary>
        /// 工具最大可添加对象个数
        /// </summary>
        private static int PlantCount = 6;
        /// <summary>
        /// 工具是否启用
        /// </summary>
        private static bool Enable;
        /// <summary>
        /// 添加的对象
        /// </summary>
        private GameObject AddObject;
        /// <summary>
        /// 当前选择的对象
        /// </summary>
        private Transform CurrentSelect;
        /// <summary>
        /// SelectionGrid组件中选中对象的序号,0开始
        /// </summary>
        private int PlantSelect;
        /// <summary>
        /// 画刷大小
        /// </summary>
        private int brushSize;
        /// <summary>
        /// 草对象随机大小范围
        /// </summary>
        private float scaleRandomMax = 1;
        /// <summary>
        /// 草对象随机大小范围
        /// </summary>
        private float scaleRandomMin = 1;
        /// <summary>
        /// 画刷密度
        /// </summary>
        private int density;
        /// <summary>
        /// 草对象数组
        /// </summary>
        private static GameObject[] Plants;
        /// <summary>
        /// 草对象缩略图数组
        /// </summary>
        private static Texture[] TexObjects;
        /// <summary>
        /// 数据存储
        /// </summary>
        private static ArtBrushToolData data ;
        #endregion

        [MenuItem("AiferuFramework/库本身的功能/4.项目使用工具收集/8.美术射线刷草工具Bata %g", false, 4008)]
        static void Open()
        {
            #region 窗口初始化
            var window = (ArtBrushToolEW)EditorWindow.GetWindowWithRect(typeof(ArtBrushToolEW), new Rect(0, 0, 386, 320), false, "Paint Detail");
            window.Show();

            #endregion
            Debug.Log(ArtBrushToolMain.ToolsDataSavePath);
            Debug.Log("ArtBrushTool初始化成功");
        }
        private void Awake()
        {
            LoadData();
            #region 初始化
            Plants = new GameObject[PlantCount];
            TexObjects = new Texture[PlantCount];
            for (int i = 0; i < PlantCount; i++)
            {
                Plants[i] = null;
            }
            Enable = true;
            #endregion
        }
        private void OnDisable()
        {
            SaveData();
            Enable = false;
            Debug.Log("ArtBrushTool关闭");
        }

        /// <summary>
        /// 每帧重绘制窗口
        /// </summary>
        void OnInspectorUpdate()
        {
            Repaint();
        }

        /// <summary>
        /// Draw
        /// </summary>
        void OnGUI()
        {
            //获取当前选择
            CurrentSelect = Selection.activeTransform;
            //Debug.Log(CurrentSelect.name);

            GUILayout.Space(20);
            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            GUILayout.BeginVertical("box", GUILayout.Width(347));
            GUILayout.BeginHorizontal();
            GUILayout.Label("Add Assets", GUILayout.Width(125));

            AddObject = (GameObject)EditorGUILayout.ObjectField("", AddObject, typeof(GameObject), false, GUILayout.Width(160));

            if (GUILayout.Button("+", GUILayout.Width(40)))
            {
                for (int i = 0; i < PlantCount; i++)
                {
                    if (Plants[i] == null)
                    {
                        Plants[i] = AddObject;
                        break;
                    }
                }
            }

            GUILayout.EndHorizontal();
            GUILayout.EndVertical();
            GUILayout.FlexibleSpace();
            GUILayout.EndHorizontal();

            for (int i = 0; i < PlantCount; i++)
            {
                if (Plants[i] != null)
                    TexObjects[i] = AssetPreview.GetAssetPreview(Plants[i]) as Texture;
                else TexObjects[i] = null;
            }

            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            GUILayout.BeginVertical("box", GUILayout.Width(347));
            PlantSelect = GUILayout.SelectionGrid(PlantSelect, TexObjects, PlantCount, "gridlist", GUILayout.Width(330), GUILayout.Height(55));

            GUILayout.BeginHorizontal();

            for (int i = 0; i < PlantCount; i++)
            {
                if (GUILayout.Button("—", GUILayout.Width(52)))
                {
                    Plants[i] = null;
                }
            }

            GUILayout.EndHorizontal();

            GUILayout.EndVertical();
            GUILayout.FlexibleSpace();
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            GUILayout.BeginVertical("box", GUILayout.Width(347));
            GUILayout.BeginHorizontal();
            GUILayout.Label("Setting", GUILayout.Width(145));
            GUILayout.EndHorizontal();
            brushSize = (int)EditorGUILayout.Slider("Brush Size", brushSize, 1, 36);
            GUILayout.Label("ScaleRandom", GUILayout.Width(145));
            scaleRandomMin = EditorGUILayout.Slider("Scale RandomMin", scaleRandomMin, 0.05f, 1.5f);
            scaleRandomMax = EditorGUILayout.Slider("Scale RandomMax", scaleRandomMax, 0.05f, 1.5f);
            density = (int)EditorGUILayout.Slider("Density", density, 1, 10);
            GUILayout.EndVertical();
            GUILayout.FlexibleSpace();
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.FlexibleSpace();
            GUILayout.BeginVertical(GUILayout.Width(347));


        }


        #region 存储数据
        private void SaveData()
        {
            if(AssetDatabase.LoadAssetAtPath<ArtBrushToolData>(ArtBrushToolMain.ToolsDataSavePath)!=null)
            {
                AssetDatabase.DeleteAsset(ArtBrushToolMain.ToolsDataSavePath);
            }
            data = ScriptableObject.CreateInstance<ArtBrushToolData>();
            data.ScaleRandomMin = scaleRandomMin;
            data.ScaleRandomMax = scaleRandomMax;
            data.Density = density;
            data.BrushSize = brushSize;
            data.PlantCount = PlantCount;
            data.Plants = Plants;
            AssetDatabase.CreateAsset(data, ArtBrushToolMain.ToolsDataSavePath);
            EditorUtility.SetDirty(data);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        private void LoadData()
        {
            data = AssetDatabase.LoadAssetAtPath<ArtBrushToolData>(ArtBrushToolMain.ToolsDataSavePath);
            if (data == null) return;
            scaleRandomMax = data.ScaleRandomMax;
            scaleRandomMin = data.ScaleRandomMin;
            density = data.Density;
            brushSize = data.BrushSize;
            PlantCount = data.PlantCount;
            Plants = data.Plants;
        }

        #endregion
    }
}
#endif