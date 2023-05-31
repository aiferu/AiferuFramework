#if UNITY_EDITOR
using UnityEngine;
using UnityEngine.SocialPlatforms;
using UnityEditor;
using System.Collections.Generic;
using System.Numerics;

namespace AiferuFramework.ArtBrushTool
{
    /// <summary>
    /// ����ˢ�ݹ���
    /// </summary>
    public class ArtBrushToolEW : EditorWindow
    {
        #region ��������
        /// <summary>
        /// ����������Ӷ������
        /// </summary>
        private static int PlantCount = 6;
        /// <summary>
        /// �����Ƿ�����
        /// </summary>
        private static bool Enable;
        /// <summary>
        /// ��ӵĶ���
        /// </summary>
        private GameObject AddObject;
        /// <summary>
        /// ��ǰѡ��Ķ���
        /// </summary>
        private Transform CurrentSelect;
        /// <summary>
        /// SelectionGrid�����ѡ�ж�������,0��ʼ
        /// </summary>
        private int PlantSelect;
        /// <summary>
        /// ��ˢ��С
        /// </summary>
        private int brushSize;
        /// <summary>
        /// �ݶ��������С��Χ
        /// </summary>
        private float scaleRandomMax = 1;
        /// <summary>
        /// �ݶ��������С��Χ
        /// </summary>
        private float scaleRandomMin = 1;
        /// <summary>
        /// ��ˢ�ܶ�
        /// </summary>
        private int density;
        /// <summary>
        /// �ݶ�������
        /// </summary>
        private static GameObject[] Plants;
        /// <summary>
        /// �ݶ�������ͼ����
        /// </summary>
        private static Texture[] TexObjects;
        /// <summary>
        /// ���ݴ洢
        /// </summary>
        private static ArtBrushToolData data ;
        #endregion

        [MenuItem("AiferuFramework/�Ȿ��Ĺ���/4.��Ŀʹ�ù����ռ�/8.��������ˢ�ݹ���Bata %g", false, 4008)]
        static void Open()
        {
            #region ���ڳ�ʼ��
            var window = (ArtBrushToolEW)EditorWindow.GetWindowWithRect(typeof(ArtBrushToolEW), new Rect(0, 0, 386, 320), false, "Paint Detail");
            window.Show();

            #endregion
            Debug.Log(ArtBrushToolMain.ToolsDataSavePath);
            Debug.Log("ArtBrushTool��ʼ���ɹ�");
        }
        private void Awake()
        {
            LoadData();
            #region ��ʼ��
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
            Debug.Log("ArtBrushTool�ر�");
        }

        /// <summary>
        /// ÿ֡�ػ��ƴ���
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
            //��ȡ��ǰѡ��
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
                if (GUILayout.Button("��", GUILayout.Width(52)))
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


        #region �洢����
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